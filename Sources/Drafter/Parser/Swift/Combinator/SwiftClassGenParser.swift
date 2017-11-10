//
//  SwiftClassParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

class SwiftClassGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [ClassNode] {
        return []
    }
}

// MARK: - Parser

/*
 definition = class_definition | protocol_definition | extension_definition
 
 class_definition = 'class' NAME generics_type? inherit_list?
 generics_type    = '<' ANY '>'
 inherit_list     = ':' (NAME)+
 ...
 */
extension SwiftClassGenParser {
//    var classDef: Parser<ClassNode> {
//        return curry(ClassNode.init)
//            <^> token(.cls) *> token(.name) => stringify
//            <*> trying(genericType) *> lookAhead(token(.colon)) *> token(.name) => toClassNode // 第一个为superClass
//            <*> lookAhead(token(.comma)) *> inheritList => stringify
//    }
    
    var genericType: Parser<String> {
        return anyToken(between: .leftAngle, and: .rightAngle) *> pure("")
    }
    
    var inheritList: Parser<[String]> {
        return token(.colon) *> token(.name).separateBy(token(.comma)) => stringify
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
