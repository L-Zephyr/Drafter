//
//  NodeConstant.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/26.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Cocoa

/// 保存类型信息的节点
class ClassNode: Node {    
    var superCls: String? = nil    // 父类
    var className: String = ""     // 类名
    var protocols: [String] = []   // 实现的协议
    var methods: [MethodNode] = [] // 方法
}

// MARK: - 自定义初始化方法

extension ClassNode {
    convenience init(_ name: String, _ superClass: String?, _ protos: [String], _ methods: [MethodNode]) {
        self.init()
        
        if let superClass = superClass, !superClass.isEmpty {
            self.superCls = superClass
        }
        self.className = name
        self.protocols = protos
        self.methods = methods
    }
    
    convenience init(clsName: String) {
        self.init(clsName, nil, [], [])
    }
    
    // 解析OC时所用的初始化方法
    convenience init(interface: InterfaceNode? = nil, implementation: ImplementationNode? = nil) {
        self.init()
        
        if let interface = interface {
            self.className = interface.className
            self.superCls = interface.superCls ?? ""
            self.protocols = interface.protocols
        }
        
        if let imp = implementation {
            self.methods = imp.methods
        }
    }
}

// MARK: - 自定义数据转换

extension ClassNode: CustomStringConvertible {
    var description: String {
        var desc = "{class: \(className)"
        
        if let superCls = superCls {
            desc.append(contentsOf: ", superClass: \(superCls)")
        }
        
        if protocols.count > 0 {
            desc.append(contentsOf: ", protocols: \(protocols.joined(separator: ", "))")
        }
        
        desc.append(contentsOf: "}")
        return desc
    }
}

extension ClassNode {
    /// 转换成JSON数据
    var toJson: String {
        return ""
    }
}

// MARK: - Merge

extension ClassNode {
    /// 将两个相同的node合并成一个
    func merge(_ node: ClassNode) {
        if className != node.className {
            return
        }
        
        // 合并协议
        for proto in node.protocols {
            if !protocols.contains(proto) {
                protocols.append(proto)
            }
        }
        // 合并方法
        self.methods.append(contentsOf: node.methods)
        
        if superCls == nil && node.superCls != nil {
            superCls = node.superCls
        }
    }
}

extension Array where Element == ClassNode {
    /// 将其他的节点集合合并到当前节点集合中
    mutating func merge(_ others: [ClassNode]) {
        let set = Set<ClassNode>(self)
        
        for node in others {
            if let index = set.index(of: node) {
                set[index].merge(node)
            } else {
                self.append(node)
            }
        }
    }
    
    /// 合并重复的结果
    var distinct: [ClassNode] {
        guard self.count > 1 else {
            return self
        }
        
        var set = Set<ClassNode>()
        for node in self {
            if let index = set.index(of: node) {
                set[index].merge(node) // 合并相同的节点
            } else {
                set.insert(node)
            }
        }
        
        return Array(set)
    }
}

// MARK: - Hashable

extension ClassNode: Hashable {
    static func ==(lhs: ClassNode, rhs: ClassNode) -> Bool {
        return lhs.className == rhs.className
    }
    
    var hashValue: Int {
        return className.hashValue
    }
}
