//
//  SwiftClassParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

class SwiftClassGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [ClassNode] {
        return classDef.continuous.run(tokens) ?? []
    }
    
    var parser: Parser<[ClassNode]> {
        return classDef.continuous
    }
}

// MARK: - Parser

/*
 definition = class_definition | protocol_definition | extension_definition
 
 
 inherit_list     = ':' (NAME)+
 ...
 */
extension SwiftClassGenParser {
    
    ///
    /**
     class_definition = 'class' NAME generics_type? super_class? protocols?
     */
    var classDef: Parser<ClassNode> {
        return curry(ClassNode.init)
            <^> token(.cls) *> token(.name) <* trying(genericType) => stringify // 类名
            <*> trying(superCls) => toClassNode // 父类
            <*> trying(protocols) => stringify // 协议列表
    }
    
    /// 解析泛型
    /**
      generics_type = '<' ANY '>'
     */
    var genericType: Parser<String> {
        return anyToken(between: .leftAngle, and: .rightAngle) *> pure("")
    }
    
    /// 父类
    var superCls: Parser<Token> {
        return token(.colon) *> token(.name)
    }
    
    /// 协议列表
    var protocols: Parser<[Token]> {
        return token(.comma) *> token(.name).separateBy(token(.comma))
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
}
