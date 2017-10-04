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
    
    /// 待解析的文件或文件夹, 目前只支持.h和.m文件
    var path: String = "" {
        didSet {
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
        for file in files {
            let lexer = SourceLexer(file: file)
            print(file)
            
            if file.isSwift {
                let parser = SwiftClassParser(lexer: lexer)
                classNodes.merge(parser.parse())
            } else {
                let parser = InterfaceParser(lexer: lexer)
                classNodes.merge(parser.parse())
            }
        }
        
        print("class node: \(classNodes.count)")
        
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
            let parser = ObjcMethodParser(lexer: lexer)
            let nodes = extractSubtree(parser.parse())
            
            DotGenerator.generate(nodes, filePath: file)
        }
    }
    
    fileprivate func extractSubtree(_ nodes: [ObjcMethodNode]) -> [ObjcMethodNode] {
        guard keywords.count != 0 else {
            return nodes
        }
        
        // 过滤出包含keyword的根节点
        var subtrees: [ObjcMethodNode] = []
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

// MARK: - OC

extension Drafter {
    func craftOCCallGraph() {
        
    }
}

// MARK: - Swift

extension Drafter {
    func craftSwiftCallGraph() {
        
    }
}

extension String {
    
    func contains(_ keywords: [String]) -> Bool {
        if keywords.isEmpty {
            return true
        }
        
        for keyword in keywords {
            if self.contains(keyword) {
                return true
            }
        }
        return false
    }
    
    var isSwift: Bool {
        return hasSuffix(".swift")
    }
}
