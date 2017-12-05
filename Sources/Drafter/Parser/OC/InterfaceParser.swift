//
//  InterfaceParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

class InterfaceParser: ParserType {
    var parser: Parser<[ClassNode]> {
        return curry({ $0.distinct }) <^> (categoryParser <|> classParser).continuous
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
    var classParser: Parser<ClassNode> {
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx : xx <xx, xx>
        let parser = curry(ClassNode.init)
            <^> token(.interface) *> token(.name) => stringify // 类名
            <*> trying (token(.colon) *> token(.name)) => stringify // 父类名
            <*> trying (token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) => stringify
        return parser
    }
    
    /// 解析分类定义
    /**
     extension = '@interface' className '(' NAME? ')' protocols
     className = NAME
     protocols = '<' NAME (',' NAME)* '>' | ''
     */
    var categoryParser: Parser<ClassNode> {
        let lParen = token(.leftParen)
        let rParen = token(.rightParen)
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx(xx?) <xx, xx>
        return curry(ClassNode.init)
            <^> token(.interface) *> token(.name) => stringify
            <*> trying(token(.name)).between(lParen, rParen) *> pure(nil) // 分类的名字是可选项, 忽略结果
            <*> trying(token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) => stringify // 协议列表
    }
}
