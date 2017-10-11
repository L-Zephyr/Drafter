//
//  InterfaceParser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - InterfaceParser

/*
 @interface文法:
 
 classDecl: '@interface' className (':' className)* protocols
 className: NAME
 protocols: '<' NAME (',' NAME)* '>' | ''
 
 Extension文法:
 
 extension: '@interface' className '(' ')' protocols
 className: NAME
 protocols: '<' NAME (',' NAME)* '>' | ''
 */

/// 解析class的定义
class InterfaceParser: BacktrackParser {
    
    /// 解析文件，返回解析结果
    ///
    /// - Returns: 解析结果的节点
    func parse() -> [ClassNode] {
        while token().type != .endOfFile {
            if token().type == .interface {
                do {
                    try classDecl()
                } catch {
                    print(error)
                }
            } else {
                consume()
            }
        }
        
        distinct() // 合并相同的节点
        
        return nodes
    }
    
    // MARK: - Private
    
    fileprivate var nodes: [ClassNode] = [] // 解析出来的类型节点
    fileprivate var currentNode: ClassNode? = nil // 当前正在解析的节点
    
    /// 合并nodes中相同的结果
    fileprivate func distinct() {
        guard nodes.count > 1 else {
            return
        }
        
        var set = Set<ClassNode>()
        for node in nodes {
            if let index = set.index(of: node) {
                set[index].merge(node) // 合并相同的节点
            } else {
                set.insert(node)
            }
        }
        
        nodes = Array(set)
    }
}

// MARK: - 文法规则解析

extension InterfaceParser {
    func classDecl() throws {
        let node = ClassNode()
        
        try match(.interface) // @interface关键字
        node.className = try match(.name).text      // 类名
        
        // 成功匹配到interface定义, 添加到节点中
        currentNode = node
        nodes.append(node)
        
        if token().type == .colon { // 类型定义，继续匹配父类
            try match(.colon)
            node.superCls = ClassNode(clsName: try match(.name).text) // 父类的名称
            
            try protocols()  // 实现的协议
        } else if token().type == .leftParen { // 碰到(说明这里为分类定义
            // TODO: 区分category
            try match(.leftParen)
            
            // 括号中没有内容则为匿名分类
            if token().type == .name {
                try match(.name)
            }
            
            try match(.rightParen)
            try protocols()
        }
        
        currentNode = nil
    }
    
    func protocols() throws {
        if token().type == .leftAngle {
            try match(.leftAngle)
            // 至少有一个协议
            let protoName = try match(.name).text
            currentNode?.protocols.append(protoName)
            
            while token().type == .comma { // 多个协议之间用逗号隔开
                try match(.comma)
                let protoName = try match(.name).text
                currentNode?.protocols.append(protoName)
            }
            try match(.rightAngle)
        }
    }
}
