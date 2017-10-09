//
//  Mapper.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/26.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

class Drafter {
    
    // MARK: - Public
    
    var mode: DraftMode = .callGraph
    var keywords: [String] = []
    var selfOnly: Bool = false // 只包含定义在用户代码中的方法节点
    
    /// 待解析的文件或文件夹, 目前只支持.h和.m文件
    var paths: String = "" {
        didSet {
            let pathValues = paths.split(by: ",")
            // 多个文件用逗号分隔
            for path in pathValues {
                var isDir: ObjCBool = ObjCBool.init(false)
                if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
                    // 如果是文件夹则获取所有.h和.m文件
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
        }
    }
    
    /// 生成调用图
    func craft() {
        switch mode {
        case .callGraph:
            craftCallGraph()
        case .inheritGraph:
            craftInheritGraph()
        case .both:
            craftInheritGraph()
            craftCallGraph()
        }
    }
    
    // MARK: - Private
    
    fileprivate var files: [String] = []
    
    fileprivate func supported(_ file: String) -> Bool {
        if file.hasSuffix(".h") || file.hasSuffix(".m") || file.hasSuffix(".swift") {
            return true
        }
        return false
    }
    
    /// 生成继承关系图
    fileprivate func craftInheritGraph() {
        var classNodes = [ClassNode]()
        
        // oc files
        for file in files.filter({ !$0.isSwift }) {
            let parser = InterfaceParser(lexer: SourceLexer(file: file))
            classNodes.merge(parser.parse())
        }
        
        // swift files
        let swiftFiles = files.filter({ $0.isSwift })
        
        // 1. 解析protocol
        var protocols = [ProtocolNode]()
        for file in swiftFiles {
            let parser = SwiftProtocolParser(lexer: SourceLexer(file: file))
            protocols.append(contentsOf: parser.parse())
        }
        
        // 2. 解析class
        for file in swiftFiles {
            let parser = SwiftClassParser(lexer: SourceLexer(file: file), protocols: protocols)
            classNodes.merge(parser.parse())
        }
        
        DotGenerator.generate(classNodes, filePath: "Inheritance")
        
        // test
        for node in classNodes {
            print(node)
        }
    }
    
    /// 生成方法调用关系图
    fileprivate func craftCallGraph() {
        for file in files.filter({ !$0.hasSuffix(".h") }) {
            let lexer = SourceLexer(file: file)
            
            var nodes = [MethodNode]()
            if file.isSwift {
                let parser = SwiftMethodParser(lexer: lexer)
                nodes.append(contentsOf: filted(parser.parse()))
            } else {
                let parser = ObjcMethodParser(lexer: lexer)
                nodes.append(contentsOf: filted(parser.parse()))
            }

            DotGenerator.generate(nodes, filePath: file)
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
    
    func filtedSelfMethod(_ methods: [MethodNode]) -> [MethodNode] {
        // 仅保留自定义方法之间的调用
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
        guard keywords.count != 0 else {
            return nodes
        }
        
        // 过滤出包含keyword的根节点
        var subtrees: [MethodNode] = []
        let filted = nodes.filter {
            $0.description.lowercased().contains(keywords)
        }
        subtrees.append(contentsOf: filted)
        
        for method in filted {
            for invoke in method.invokes {
                if let index = nodes.index(where: { $0.hashValue == invoke.hashValue }) {
                    subtrees.append(nodes[index])
                }
            }
        }
        
        return subtrees
    }
    
}
