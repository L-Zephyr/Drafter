//
//  InterfaceParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation
import SwiftyParse

// 解析OC中的Interface定义
class InterfaceParser: ConcreteParserType {
    var parser: TokenParser<[InterfaceNode]> {
//        return curry({ $0.merged() }) <^> (categoryParser <|> classParser).continuous
        return (categoryParser <|> classParser).continuous
    }
}

// MARK: - 类型转换

extension Parser where Result == Array<InterfaceNode>, Stream == Tokens {
    // 将结果直接转换成ClassNode类型
    var toClassNode: TokenParser<[ClassNode]> {
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
    var classParser: TokenParser<InterfaceNode> {
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx : xx <xx, xx>
        let parser = curry(InterfaceNode.init)
            <^> token(.interface) *> token(.name) => stringify // 类名
            <*> (token(.colon) *> token(.name)).try => stringify // 父类名
            <*> (token(.name).sepBy(token(.comma)).between(lAngle, rAngle)).try => stringify // 协议
            <*> anyTokens(until: token(.end)).map { ObjcMethodParser().declsParser.run($0) ?? [] } // 方法定义
        return parser
    }
    
    /// 解析分类定义
    /**
     extension = '@interface' className '(' NAME? ')' protocols
     className = NAME
     protocols = '<' NAME (',' NAME)* '>' | ''
     */
    var categoryParser: TokenParser<InterfaceNode> {
        let lParen = token(.leftParen)
        let rParen = token(.rightParen)
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx(xx?) <xx, xx>
        return curry(InterfaceNode.init)
            <^> token(.interface) *> token(.name) => stringify
            <*> (token(.name)).try.between(lParen, rParen) *> pure(nil) // 分类的名字是可选项, 忽略结果
            <*> (token(.name).sepBy(token(.comma)).between(lAngle, rAngle)).try => stringify // 协议列表
            <*> anyTokens(until: token(.end)).map { ObjcMethodParser().declsParser.run($0) ?? [] } 
    }
}
