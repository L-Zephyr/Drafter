//
//  Passes.swift
//  Drafter
//
//  Created by LZephyr on 2018/9/1.
//

import Foundation

/// 合并重复类型的节点
class DistinctPass: Pass {
    func run(onOCTypes ocTypes: [ObjcTypeNode], swiftTypes: [SwiftTypeNode]) -> ([ObjcTypeNode], [SwiftTypeNode]) {
        // 1. 合并重复的Interface节点
        var interfaceSet = Set<InterfaceNode>()
        for interface in ocTypes.interfaces {
            if let index = interfaceSet.index(of: interface) {
                interfaceSet[index].superCls = select(interfaceSet[index].superCls, interface.superCls)
                interfaceSet[index].protocols.append(contentsOf: interface.protocols)
            } else {
                interfaceSet.insert(interface)
            }
        }
        // 2. 合并重复的Implementation节点
        var impSet = Set<ImplementationNode>()
        for imp in ocTypes.implementations {
            if let index = impSet.index(of: imp) {
                impSet[index].methods.append(contentsOf: imp.methods)
            } else {
                impSet.insert(imp)
            }
        }
        
        let ocNodes = interfaceSet.map { ObjcTypeNode.interface($0) } + impSet.map { ObjcTypeNode.implementaion($0) }

        // 3. 将swfit中extension定义的方法合并到class中
        let clsDic = swiftTypes.classes.toDictionary { node -> String? in
            return node.className
        }
        let swiftNodes = swiftTypes.map { type -> SwiftTypeNode in
            if case .extension(let ext) = type, let cls = clsDic[ext.name] {
                cls.protocols.append(contentsOf: ext.protocols)
                cls.methods.append(contentsOf: ext.methods)
            }
            return type
        }

        return (ocNodes, swiftNodes)
    }
    
    func run(onClasses classes: [ClassNode]) -> [ClassNode] {
        guard classes.count > 1 else {
            return classes
        }
        
        var set = Set<ClassNode>()
        for node in classes {
            if let index = set.index(of: node) {
                set[index].merge(node) // 合并相同的节点
            } else {
                set.insert(node)
            }
        }
        
        return Array(set)
    }
}

fileprivate extension ClassNode {
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
        // 合并父类
        if superCls.isEmpty && !node.superCls.isEmpty {
            superCls = node.superCls
        }
    }
}

