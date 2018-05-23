//
//  InterfaceParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

// 解析OC中的Interface定义
class InterfaceParser: ParserType {
    var parser: Parser<[InterfaceNode]> {
//        return curry({ $0.merged() }) <^> (categoryParser <|> classParser).continuous
        return (categoryParser <|> classParser).continuous
    }
}

// MARK: - 类型转换

extension Parser where T == Array<InterfaceNode> {
    // 将结果直接转换成ClassNode类型
    var toClassNode: Parser<[ClassNode]> {
        return self.map { (interfaces) -> [ClassNode] in
            let clsNodes = interfaces.map { ClassNode(interface: $0) }
            return clsNodes.merged()
        }
    }
}

// MARK: - Parser

extension InterfaceParser {
    
    /// 解析类型定义
    /**
     classDecl = '@interface' className (':' className)* protocols
     className = NAME
     protocols = '<' NAME (',' NAME)* '>' | ''
     */
    var classParser: Parser<InterfaceNode> {
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx : xx <xx, xx>
        let parser = curry(InterfaceNode.init)
            <^> token(.interface) *> token(.name) => stringify // 类名
            <*> trying (token(.colon) *> token(.name)) => stringify // 父类名
            <*> trying (token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) => stringify // 协议
        return parser
    }
    
    /// 解析分类定义
    /**
     extension = '@interface' className '(' NAME? ')' protocols
     className = NAME
     protocols = '<' NAME (',' NAME)* '>' | ''
     */
    var categoryParser: Parser<InterfaceNode> {
        let lParen = token(.leftParen)
        let rParen = token(.rightParen)
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx(xx?) <xx, xx>
        return curry(InterfaceNode.init)
            <^> token(.interface) *> token(.name) => stringify
            <*> trying(token(.name)).between(lParen, rParen) *> pure(nil) // 分类的名字是可选项, 忽略结果
            <*> trying(token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) => stringify // 协议列表
    }
}
