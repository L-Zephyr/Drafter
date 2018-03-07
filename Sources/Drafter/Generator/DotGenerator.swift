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
    
    /// 在当前位置生成类图
    ///
    /// - Parameters:
    ///   - clsNodes:  类型节点数据
    ///   - protocols: 协议节点数据
    ///   - filePath:  路径，作为结果图片命名的前缀
    @discardableResult
    static func generate(classes clsNodes: [ClassNode], protocols: [ProtocolNode], filePath: String) -> String {
        let dot = DotGenerator()
        var nodesSet = Set<String>()
        
        dot.begin(name: "Inheritance")
        
        // class node
        for cls in clsNodes {
            // 类节点
            if !nodesSet.contains(cls.className) {
                nodesSet.insert(cls.className)
                dot.append(cls, label: "\(cls.className)")
            }
            
            for proto in cls.protocols {
                if !nodesSet.contains(proto) {
                    nodesSet.insert(proto)
                    dot.append(proto, label: "<<protocol>>\n\(proto)")
                }
                dot.point(from: cls, to: proto, emptyArrow: true, dashed: true)
            }
            
            // 父类
            if let superCls = cls.superCls {
                if !nodesSet.contains(superCls) {
                    nodesSet.insert(superCls)
                    dot.append(superCls, label: superCls)
                }
                dot.point(from: cls, to: superCls, emptyArrow: true)
            }
        }
        
        // 剩余的Protocol
        for proto in protocols {
            if !nodesSet.contains(proto.name) {
                nodesSet.insert(proto.name)
                dot.append(proto, label: "<<protocol>>\n\(proto.name)")
            }
        }
        
        dot.end()
        
        return dot.create(file: filePath)
    }
    
    /// 在当前位置生成调用关系图
    ///
    /// - Parameters:
    ///   - methods: 方法节点
    ///   - filePath: 源代码文件的路径
    @discardableResult
    static func generate(_ methods: [MethodNode], filePath: String) -> String {
        // 生成Dot描述
        let dot = DotGenerator()
        dot.begin(name: "CallGraph")
        
        var nodesSet = Set<Int>()
        var relationSet = Set<String>() // 避免重复连线
        
        for method in methods {
            // 添加节点定义
            if !nodesSet.contains(method.hashValue) {
                dot.append(method, label: method.description)
                nodesSet.insert(method.hashValue)
            }
            
            for invoke in method.invokes {
                if !nodesSet.contains(invoke.hashValue) {
                    // 优先显示详细的信息
                    if let index = methods.index(where: { $0.hashValue == invoke.hashValue }) {
                        dot.append(methods[index], label: methods[index].description)
                        nodesSet.insert(methods[index].hashValue)
                    } else {
                        dot.append(invoke, label: invoke.description)
                        nodesSet.insert(invoke.hashValue)
                    }
                }
                
                let relation = "\(method.hashValue)\(invoke.hashValue)"
                if !relationSet.contains(relation) && method.hashValue != invoke.hashValue {
                    dot.point(from: method, to: invoke)
                    relationSet.insert(relation)
                }
            }
        }
        
        dot.end()
        
        return dot.create(file: filePath)
    }
    
    // MARK: - Private
    
    fileprivate var dot: String = ""
    
    fileprivate func create(file filePath: String) -> String {
        // 写入文件
        let filename = URL(fileURLWithPath: filePath).lastPathComponent
        let dotFile = "./\(filename).dot"
        let target = "./\(filename).png"
        
        // 创建Dot文件
        if FileManager.default.fileExists(atPath: dotFile) {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
        }
        _ = FileManager.default.createFile(atPath: dotFile, contents: dot.data(using: .utf8), attributes: nil)
        
        // 生成png
        Executor.execute("dot", "-T", "png", dotFile, "-o", "\(target)", help: "Make sure Graphviz is successfully installed.")
        
        // 删除.dot文件
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
        
        return target
    }
}

// MARK: - Dot Generate Method

fileprivate extension DotGenerator {
    
    func begin(name: String) {
        dot.append(contentsOf: "digraph \(name) { node [shape=\"record\"];")
    }
    
    func end() {
        dot.append(contentsOf: "}")
    }
    
    func append<T: Hashable>(_ node: T, label: String) {
        var escaped = label
        escaped = escaped.replacingOccurrences(of: "<", with: "\\<")
        escaped = escaped.replacingOccurrences(of: ">", with: "\\>")
        escaped = escaped.replacingOccurrences(of: "->", with: "\\-\\>")
        
        dot.append(contentsOf: "\(node.hashValue) [label=\"\(escaped)\"];")
    }
    
    func point<T: Hashable, A: Hashable>(from: T, to: A, emptyArrow: Bool = false, dashed: Bool = false) {
        var style = ""
        if emptyArrow {
            style.append(contentsOf: "arrowhead = \"empty\" ")
        }
        if dashed {
            style.append(contentsOf: "style=\"dashed\"")
        }
        
        if !style.isEmpty {
            dot.append(contentsOf: "\(from.hashValue)->\(to.hashValue)[\(style)];")
        } else {
            dot.append(contentsOf: "\(from.hashValue)->\(to.hashValue);")
        }
    }
}
