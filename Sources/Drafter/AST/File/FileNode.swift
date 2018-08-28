//
//  FileNode.swift
//  Drafter
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation
import PathKit

/// 通用的结果类型，表示一个源码文件的解析结果
struct FileNode: AutoCodable {
    let md5: String // 源码文件内容的md5
    let drafterVersion: String // drafter的版本
    let path: String    // 文件的绝对路径
    let type: FileType  // 文件类型
    
    // Swift文件用这个
    let swiftTypes: [SwiftTypeNode]
    
    // OC文件用这个
    let interfaces: [InterfaceNode]
    let implementations: [ImplementationNode]
}

// MARK: - 结果处理

extension Array where Element == FileNode {
    /// 对结果进行处理，整合InterfaceNode和ImplementationNode，去重，返回统一的ClassNode类型
    func processed() -> [ClassNode] {
        var results: [ClassNode] = []
        
        // 1. 将OC的Interface和Implementation整合成Class
        let interfaces = self.filter({ $0.type != .swift }).flatMap({ $0.interfaces }).merged()
        let impDic = self.filter({ $0.type != .swift }).flatMap({ $0.implementations }).merged()
        
        for interface in interfaces {
            if let imp = impDic[interface.className] {
                results.append(ClassNode(interface: interface, implementation: imp))
            }
        }
        
        // 2. 加上swift的Class
        results.append(contentsOf: self.filter({ $0.type == .swift }).flatMap({ $0.swiftTypes }).preprocessed)
        
        // 3. 合并相同结果
        return results.merged()
    }
}

// MARK: - SwiftTypeNode预处理

extension Array where Element == SwiftTypeNode {
    
    /// 对结果进行预处理，将extension中定义的方法合并到ClassNode中
    var preprocessed: [ClassNode] {
        let clsDic = self.classes.toDictionary { (node) -> Int? in
            return node.hashValue
        }
        
        for exten in self.extensions {
            // 自定义类型的扩展
            if clsDic.keys.contains(exten.hashValue) {
                clsDic[exten.hashValue]?.methods.append(contentsOf: exten.methods)
                clsDic[exten.hashValue]?.protocols.append(contentsOf: exten.protocols)
            }
        }
        
        return Array<ClassNode>(clsDic)
    }
}

// MARK: ClassNode去重

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
        // 合并父类
        if superCls.isEmpty && !node.superCls.isEmpty {
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
    func merged() -> [ClassNode] {
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

// MARK: InterfaceNode去重

extension Array where Element == InterfaceNode {
    /// 合并重复节点
    func merged() -> [InterfaceNode] {
        var set = Set<InterfaceNode>()
        
        for interface in self {
            if let index = set.index(of: interface) {
                set[index].superCls = select(set[index].superCls, interface.superCls)
                set[index].protocols.append(contentsOf: interface.protocols)
            } else {
                set.insert(interface)
            }
        }
        
        return Array(set)
    }
}

// MARK: ImplementationNode去重

fileprivate extension Array where Element == ImplementationNode {
    /// 合并相同类型的Imp节点，保存在字典中返回
    func merged() -> [String: ImplementationNode] {
        var impDic = [String: ImplementationNode]()
        for imp in self {
            if impDic.keys.contains(imp.className) {
                impDic[imp.className]?.methods.append(contentsOf: imp.methods)
            } else {
                impDic[imp.className] = imp
            }
        }
        
        return impDic
    }
}
