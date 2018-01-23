//
//  Mapper.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/26.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

let maxConcurrent: Int = 4

class Drafter {
    
    // MARK: - Public
    
    var mode: DraftMode = .invokeGraph
    var outputType: DraftOutputType = .html
    var keywords: [String] = []
    var selfOnly: Bool = false // 只包含定义在用户代码中的方法节点
    
    /// 待解析的文件或文件夹, 目前只支持.h、.m和.swift文件
    var paths: String = "" {
        didSet {
            let pathValues = paths.split(by: ",")
            // 多个文件用逗号分隔
            for path in pathValues {
                var isDir: ObjCBool = ObjCBool.init(false)
                if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
                    // 如果是文件夹则遍历所有文件
                    if isDir.boolValue, let enumerator = FileManager.default.enumerator(atPath: path) {
                        while let file = enumerator.nextObject() as? String {
                            if supported(file) {
                                files.append("\(path)/\(file)")
                            }
                        }
                    } else {
                        files = [path]
                    }
                } else {
                    print("File: \(path) not exist")
                }
            }
            
            // 如果输出类型为html，则需要对数据做进一步的处理
        }
    }
    
    /// 生成调用图
    func craft() {
        if outputType == .html {
            craftInheritGraph()
            craftinvokeGraph()
        } else { // 输出为图片的话需要根据选项做进一步的处理
            switch mode {
            case .invokeGraph:
                craftinvokeGraph()
            case .inheritGraph:
                craftInheritGraph()
            case .both:
                craftInheritGraph()
                craftinvokeGraph()
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate var files: [String] = []
    fileprivate let semaphore = DispatchSemaphore(value: maxConcurrent)
    
    fileprivate func craftInheritGraph() {
        var classes = [ClassNode]()
        var protocols = [ProtocolNode]()
        let writeQueue = DispatchQueue(label: "WriteClass")

        // 解析OC类型
        func parseObjcClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let result = InterfaceParser().parser.run(tokens) ?? []
            writeQueue.sync {
                classes.merge(result)
            }
        }

        // 解析swift类型
        func parseSwiftClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let (protos, cls) = SwiftInheritParser().parser.run(tokens) ?? ([], [])
            writeQueue.sync {
                protocols.append(contentsOf: protos)
                classes.merge(cls)
            }
        }

        // 1. 解析OC文件
        for file in files.filter({ !$0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseObjcClass(file)
                self.semaphore.signal()
            }
        }

        // 2. 解析swift文件
        for file in files.filter({ $0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseSwiftClass(file)
                self.semaphore.signal()
            }
        }

        waitUntilFinished()
        
        // TODO: 输出HTML或png
        
        if outputType == .html {
            
        } else {
            
        }

        // 3. 过滤、生成结果
        classes = classes.filter({ $0.className.contains(keywords) })
        protocols = protocols.filter({ $0.name.contains(keywords) })

        let resultPath = DotGenerator.generate(classes: classes, protocols: protocols, filePath: "Inheritance")

        // Log result
        for node in classes {
            print(node)
        }
        
        Executor.execute("open", resultPath, help: "Auto open failed")
    }
    
    /// 生成方法调用关系图
    fileprivate func craftinvokeGraph() {
        var results = [String: [MethodNode]]()
        
        func parseMethods(_ file: String) -> [MethodNode] {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            var nodes = [MethodNode]()
            
            if file.isSwift {
                let result = SwiftMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: result)
            } else {
                let result = ObjcMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: result)
            }
            return nodes
        }
        
        // 1. 解析方法调用
        let sources = files.filter({ !$0.hasSuffix(".h") })
        for file in sources {
            semaphore.wait()
            DispatchQueue.global().async {
                results[file] = parseMethods(file)
                self.semaphore.signal()
            }
        }

        waitUntilFinished()
        
        // TODO:
        
        // 2. 过滤、生成结果
        var outputFiles = [String]()
        for (file, nodes) in results {
            outputFiles.append(DotGenerator.generate(filted(nodes), filePath: file))
        }
        
        // 如果只有一张图片则自动打开
        if outputFiles.count == 1 {
            Executor.execute("open", outputFiles[0], help: "Auto open failed")
        }
    }
    
    /// 等待直到所有任务完成
    func waitUntilFinished() {
        for _ in 0..<maxConcurrent {
            semaphore.wait()
        }
        for _ in 0..<maxConcurrent {
            semaphore.signal()
        }
    }
}

// MARK: - 过滤方法

fileprivate extension Drafter {
    
    func filted(_ methods: [MethodNode]) -> [MethodNode] {
        var methods = methods
        methods = filtedSelfMethod(methods)
        methods = extractSubtree(methods)
        return methods
    }
    
    /// 仅保留自定义方法之间的调用
    func filtedSelfMethod(_ methods: [MethodNode]) -> [MethodNode] {
        if selfOnly {
            var selfMethods = Set<Int>()
            for method in methods {
                selfMethods.insert(method.hashValue)
            }
            
            return methods.map({ (method) -> MethodNode in
                var selfInvokes = [MethodInvokeNode]()
                for invoke in method.invokes {
                    if selfMethods.contains(invoke.hashValue) {
                        selfInvokes.append(invoke)
                    }
                }
                method.invokes = selfInvokes
                return method
            })
        }
        return methods
    }
    
    /// 根据关键字提取子树
    func extractSubtree(_ nodes: [MethodNode]) -> [MethodNode] {
        guard keywords.count != 0, nodes.count != 0 else {
            return nodes
        }
        
        // 过滤出包含keyword的根节点
        var subtrees: [MethodNode] = []
        let filted = nodes.filter {
            $0.description.contains(keywords)
        }
        subtrees.append(contentsOf: filted)
        
        // 递归获取节点下面的调用分支
        func selfInvokes(_ invokes: [MethodInvokeNode], _ subtrees: [MethodNode]) -> [MethodNode] {
            guard invokes.count != 0 else {
                return subtrees
            }
            
            let methods = nodes.filter({ (method) -> Bool in
                invokes.contains(where: { $0.hashValue == method.hashValue }) &&
                !subtrees.contains(where: { $0.hashValue == method.hashValue })
            })
            
            return selfInvokes(methods.reduce([], { $0 + $1.invokes}), methods + subtrees)
        }
        
        subtrees.append(contentsOf: selfInvokes(filted.reduce([], { $0 + $1.invokes}), subtrees))
        
        return subtrees
    }
}

// MARK: - 文件处理

fileprivate extension Drafter {
    
    func supported(_ file: String) -> Bool {
        if file.hasSuffix(".h") || file.hasSuffix(".m") || file.hasSuffix(".swift") {
            return true
        }
        return false
    }

}
