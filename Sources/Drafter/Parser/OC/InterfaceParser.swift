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
        return singleParser.continuous
    }
}

// MARK: - Parser

extension InterfaceParser {

    /// 解析单个类型的Parser
    var singleParser: TokenParser<InterfaceNode> {
        return categoryParser <|> classParser
    }
    
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
            <^> token(.interface) *> token(.name) <* genericType => stringify // 类名
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
            <^> token(.interface) *> token(.name) <* genericType => stringify
            <*> token(.name).try.between(lParen, rParen) *> pure(nil) // 分类的名字是可选项, 忽略结果
            <*> token(.name).sepBy1(token(.comma)).between(lAngle, rAngle).try => stringify // 协议列表
            <*> anyTokens(until: token(.end)).map { ObjcMethodParser().declsParser.run($0) ?? [] }
    }
    
    /// 解析泛型定义
    /// generic = '<' NAME '>'
    var genericType: TokenParser<String?> {
        return stringify <^>
            token(.name).between(token(.leftAngle), token(.rightAngle)).try
    }
}
