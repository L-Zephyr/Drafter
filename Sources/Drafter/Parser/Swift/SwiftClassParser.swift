//
//  SwiftClassParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

class SwiftClassParser: ParserType {
    
    var parser: Parser<[ClassNode]> {
        return distinct <^> typesParser.continuous
    }
}

extension SwiftClassParser {
    /// 纠正结果中的protocols数据
    func run(_ tokens: [Token], _ protos: [ProtocolNode]) -> [ClassNode]? {
        var set = Set<String>()
        for proto in protos {
            set.insert(proto.name)
        }
        
        return self.parser.map { clsList in
            for cls in clsList {
                if let name = cls.superCls, set.contains(name) {
                    cls.superCls = nil
                    cls.protocols.insert(name, at: 0)
                }
            }
            return clsList
        }.run(tokens) 
    }
}

// MARK: - Parser

/*
 definition = class_definition | protocol_definition | extension_definition
 */
extension SwiftClassParser {
    
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

extension SwiftClassParser {
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
