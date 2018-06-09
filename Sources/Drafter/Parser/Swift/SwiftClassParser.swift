//
//  SwiftClassParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

// MARK: - SwiftClassParser

class SwiftClassParser: ConcreteParserType {
    var parser: TokenParser<[ClassNode]> {
        return curry({ $0.merged() }) <^> classParser.continuous
    }
}

// MARK: - class parser

extension SwiftClassParser {
    
    var classParser: TokenParser<ClassNode> {
        return classDef
    }
    
    /// 解析class和struct的定义
    /**
     class_definition = 'class' NAME generics_type? super_class? ',' protocols?
     */
    var classDef: TokenParser<ClassNode> {
        // TODO: 区分struct和class
        return curry(ClassNode.init)
            <^> pure(true)
            <*> (token(.cls) <|> token(.structure)) *> token(.name) <* genericType.try => stringify // 类名
            <*> superCls.try => stringify // 父类
            <*> (token(.comma) *> protocols).try => stringify // 协议列表
            <*> anyTokens(inside: token(.leftBrace), and: token(.rightBrace)).map { SwiftMethodParser().parser.run($0) ?? [] } // 方法
    }
    
    /// 解析泛型
    /**
      generics_type = '<' ANY '>'
     */
    var genericType: TokenParser<String> {
        return anyTokens(inside: token(.leftAngle), and: token(.rightAngle)) *> pure("")
    }
    
    /// 父类
    /**
     super_class = ':' NAME
     */
    var superCls: TokenParser<Token> {
        return token(.colon) *> token(.name)
    }
    
    /// 协议列表
    /**
     protocols = NAME (',' NAME)*
     */
    var protocols: TokenParser<[Token]> {
        return token(.name).separateBy(token(.comma))
    }
}

