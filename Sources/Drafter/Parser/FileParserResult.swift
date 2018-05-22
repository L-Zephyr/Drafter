//
//  FileParserResult.swift
//  Drafter
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation

/// 通用的结果类型，表示一个源码文件的解析结果
struct FileParserResult: AutoCodable {
    let md5: String // 源码文件内容的md5
    let drafterVersion: String // drafter的版本
    let path: String
    
    let isSwift: Bool
    
    // Swift文件用这个
    let swiftClasses: [ClassNode]
    
    // OC文件用这个
    let interfaces: [InterfaceNode]
    let implementations: [ImplementationNode]
}

// MARK: - 结果处理

extension Array where Element == FileParserResult {
    /// 对结果进行处理，整合InterfaceNode和ImplementationNode，去重，返回统一的ClassNode类型
    func processed() -> [ClassNode] {
        var results: [ClassNode] = []
        
        // 1. 将OC的Interface和Implementation整合成Class
        
        
        return results
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
