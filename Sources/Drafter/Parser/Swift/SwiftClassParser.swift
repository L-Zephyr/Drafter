//
//  SwiftClassParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

// MARK: - SwiftClassParser

class SwiftClassParser: ParserType {
    var parser: Parser<[ClassNode]> {
        return curry({ $0.distinct }) <^> classParser.continuous
    }
}

// MARK: - class parser

extension SwiftClassParser {
    
    var classParser: Parser<ClassNode> {
        return classDef <|> extensionDef
    }
    
    /// 解析class和struct的定义
    /**
     class_definition = 'class' NAME generics_type? super_class? ',' protocols?
     */
    var classDef: Parser<ClassNode> {
        // TODO: 区分struct和class
        return curry(ClassNode.init)
            <^> (token(.cls) <|> token(.structure)) *> token(.name) <* trying (genericType) => stringify // 类名
            <*> trying (superCls) => stringify // 父类
            <*> trying (token(.comma) *> protocols) => stringify // 协议列表
    }
    
    /// 解析extension定义
    /**
     extension_definition = 'extension' NAME (':' protocols)?
     */
    var extensionDef: Parser<ClassNode> {
        return curry(ClassNode.init)
            <^> token(.exten) *> token(.name) => stringify
            <*> pure(nil)
            <*> trying (token(.colon) *> protocols) => stringify
    }
    
    /// 解析泛型
    /**
      generics_type = '<' ANY '>'
     */
    var genericType: Parser<String> {
        return anyTokens(inside: token(.leftAngle), and: token(.rightAngle)) *> pure("")
    }
    
    /// 父类
    /**
     super_class = ':' NAME
     */
    var superCls: Parser<Token> {
        return token(.colon) *> token(.name)
    }
    
    /// 协议列表
    /**
     protocols = NAME (',' NAME)*
     */
    var protocols: Parser<[Token]> {
        return token(.name).separateBy(token(.comma))
    }
}
