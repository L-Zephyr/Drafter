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
    var superCls: String? = nil // 父类
    var className: String = ""     // 类名
    var protocols: [String] = []   // 实现的协议
    
    init(_ name: String, _ superClass: String?, _ protos: [String]) {
        if let superClass = superClass, !superClass.isEmpty {
            superCls = superClass
        }
        className = name
        protocols = protos
    }
}

extension ClassNode {
    convenience init(clsName: String) {
        self.init(clsName, nil, [])
    }
    
    convenience init() {
        self.init("", nil, [])
    }
}

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

// MARK: - Merge

extension ClassNode {
    /// 将两个node合并成一个
    func merge(_ node: ClassNode) {
        for proto in node.protocols {
            if !protocols.contains(proto) {
                protocols.append(proto)
            }
        }
        
        if superCls == nil && node.superCls != nil {
            superCls = node.superCls
        }
    }
}

extension Array where Element == ClassNode {
    mutating func merge(_ nodes: [ClassNode]) {
        let set = Set<ClassNode>(self)
        
        for node in nodes {
            if let index = set.index(of: node) {
                set[index].merge(node)
            } else {
                self.append(node)
            }
        }
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
