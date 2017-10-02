//
//  Generator.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/26.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 遍历AST并生成dot
class DotGenerator {
    
    // MARK: - Public
    
    static func generate(_ nodes: [ClassNode], filePath: String) {
        let dot = DotGenerator()
        dot.begin(name: "InheritGraph")
        
        var set = Set<ClassNode>()
        for cls in nodes {
            if set.contains(cls) {
                set.insert(cls)
                dot.append(cls, label: cls.description)
            }
        }
    }
    
    static func generate(_ methods: [ObjcMethodNode], filePath: String) {
        // 生成Dot描述
        let dot = DotGenerator()
        dot.begin(name: "CallGraph")
        
        var set = Set<Int>()
        for method in methods {
            if !set.contains(method.hashValue) {
                dot.append(method, label: method.description)
                set.insert(method.hashValue)
            }
            
            for invoke in method.invokes {
                if !set.contains(invoke.hashValue) {
                    dot.append(invoke, label: invoke.description)
                    set.insert(invoke.hashValue)
                }
                dot.point(from: method, to: invoke)
            }
        }
        
        dot.end()
        
        create(dot: dot.dot, to: filePath)
    }
    
    // MARK: - Private
    
    fileprivate var dot: String = ""
    
    fileprivate static func create(dot code: String, to filePath: String) {
        // 写入文件
        let filename = URL(fileURLWithPath: filePath).lastPathComponent
        let dotFile = "./\(filename).dot"
        let target = "./\(filename).png"
        
        // 创建Dot文件
        if FileManager.default.fileExists(atPath: dotFile) {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
        }
        _ = FileManager.default.createFile(atPath: dotFile, contents: code.data(using: .utf8), attributes: nil)
        
        // 生成png
        let out = Executor.execute("dot", "-T", "png", dotFile, "-o", "\(target)")
        
        print(out)
        
        // 删除.dot文件
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
    }
}

// MARK: - Dot Generate Method

fileprivate extension DotGenerator {
    
    func begin(name: String) {
        dot.append(contentsOf: "digraph \(name) {")
    }
    
    func end() {
        dot.append(contentsOf: "}")
    }
    
    func append<T: Hashable>(_ node: T, label: String) {
        dot.append(contentsOf: "\(node.hashValue) [label=\"\(label)\"];")
    }
    
    func point<T: Hashable, A: Hashable>(from: T, to: A) {
        dot.append(contentsOf: "\(from.hashValue)->\(to.hashValue);")
    }
}
