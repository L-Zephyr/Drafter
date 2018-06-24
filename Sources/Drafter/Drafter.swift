//
//  Mapper.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/26.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation
import PathKit

let OutputFolder = "DrafterStage"
let DataPlaceholder = "DrafterDataPlaceholder"
let DrafterVersion = "0.4.1"

class Drafter {
    
    // MARK: - Public
    
    var mode: DraftMode = .invokeGraph
    var outputType: DraftOutputType = .html
    var keywords: [String] = []
    var selfOnly: Bool = false // 只包含定义在用户代码中的方法节点
    var disableAutoOpen: Bool = false // 解析完成不要自动打开结果
    
    /// 等待处理的所有源文件
    fileprivate var files: [Path] = []
    
    /// 待解析的文件或文件夹, 目前只支持.h、.m和.swift文件
    var paths: String = "" {
        didSet {
            // 多个文件用逗号分隔
            let pathValues = paths.split(by: ",")
            
            files = pathValues
                .map {
                    return Path($0)
                }
                .flatMap { (path) -> [Path] in
                    guard path.exists else {
                        return []
                    }
                    return path.files
                }
        }
    }
    
    /// 生成调用图
    func craft() {
        if outputType == .html {
            craftHTML()
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
    
    /// 解析所有输入并生成一个HTML的输出
    func craftHTML() {
        // TODO: 重构
        let classNodes = ParserRunner.runner.parse(files: files)
        
        // 格式化
        var jsonString: String? = nil
        let jsonDic = classNodes.map { $0.toTemplateJSON() }
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted)
            jsonString = String(data: data, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
        
        guard let json = jsonString else {
            print("Fail to generate json data!")
            return
        }
        
        // 目标输出位置
        let targetFolder = "./\(OutputFolder)"
        let targetHtml = "\(targetFolder)/index.html"
        let targetJs = "\(targetFolder)/bundle.js"
        
        // 前端模板位置
        let templateHtml = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".drafter/index.html").path
        let templateJs = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".drafter/bundle.js").path
        
        guard FileManager.default.fileExists(atPath: templateHtml), FileManager.default.fileExists(atPath: templateJs) else {
            print("Error: Missing drafter template files. Try to reinstall Drafter")
            return
        }
        
        do {
            // 创建文件夹
            if FileManager.default.fileExists(atPath: targetFolder) {
                try FileManager.default.removeItem(atPath: targetFolder)
            }
            try FileManager.default.createDirectory(atPath: targetFolder, withIntermediateDirectories: true, attributes: nil)
            
            var htmlContent = try String(contentsOfFile: templateHtml)
            htmlContent = htmlContent.replacingOccurrences(of: DataPlaceholder, with: json)
            
            // 创建HTML文件
            if FileManager.default.fileExists(atPath: targetHtml) {
                try FileManager.default.removeItem(atPath: targetHtml)
            }
            FileManager.default.createFile(atPath: targetHtml, contents: htmlContent.data(using: .utf8), attributes: nil)
            
            try FileManager.default.copyItem(atPath: templateJs, toPath: targetJs)
        } catch {
            print("Error: Fail to copy resource!")
        }
        
        print("Parse result save to './DrafterStage/index.html'")
        
        // 自动打开网页
        if !disableAutoOpen {
            Executor.execute("open", targetHtml, help: "Auto open failed")
        }
    }
}

// MARK: - Deprecated

fileprivate extension Drafter {
    /// 生成类继承关系图
    fileprivate func craftInheritGraph() {
        var (classes, protocols) = ParserRunner.runner.parseInerit(files: files)
        
        // 过滤、生成结果
        classes = classes.filter({ $0.className.contains(keywords) })
        protocols = protocols.filter({ $0.name.contains(keywords) })
        
        let resultPath = DotGenerator.generate(classes: classes, protocols: protocols, filePath: "Inheritance")
        
        // Log result
        for node in classes {
            print(node)
        }
        
        if !disableAutoOpen {
            Executor.execute("open", resultPath, help: "Auto open failed")
        }
    }
    
    /// 生成方法调用关系图
    fileprivate func craftinvokeGraph() {
        // 1. 解析每个文件中的方法
        let results = ParserRunner.runner.parseMethods(files: files)
        
        // 2. 过滤、生成结果
        var outputFiles = [String]()
        for (file, nodes) in results {
            outputFiles.append(DotGenerator.generate(filted(nodes), filePath: file))
        }
        
        // 如果只有一张图片则自动打开
        if outputFiles.count == 1, !disableAutoOpen {
            Executor.execute("open", outputFiles[0], help: "Auto open failed")
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
