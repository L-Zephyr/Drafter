//
//  SwiftClassParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

class SwiftClassGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [ClassNode] {
        return parser.run(tokens) ?? []
    }
    
    var parser: Parser<[ClassNode]> {
        return distinct <^> typesParser.continuous
    }
}

// MARK: - Parser

/*
 definition = class_definition | protocol_definition | extension_definition
 */
extension SwiftClassGenParser {
    
    var typesParser: Parser<ClassNode> {
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
            <*> trying (superCls) => toClassNode // 父类
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
            <*> token(.colon) *> protocols => stringify
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
        return token(.name).separateBy(token(.comma)) <|> { [$0] } <^> token(.name)
    }
}

extension SwiftClassGenParser {
    var toClassNode: (Token?) -> ClassNode? {
        return { token in
            if let token = token {
                return ClassNode(clsName: token.text)
            } else {
                return nil
            }
        }
    }
    
    func distinct(_ nodes: [ClassNode]) -> [ClassNode] {
        guard nodes.count > 1 else {
            return nodes
        }
        
        var set = Set<ClassNode>()
        for node in nodes {
            if let index = set.index(of: node) {
                set[index].merge(node) // 合并相同的节点
            } else {
                set.insert(node)
            }
        }
        
        return  Array(set)
    }
}
