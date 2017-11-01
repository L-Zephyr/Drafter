//
//  InterfaceGenParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

/*
 @interface:
 classDecl = '@interface' className (':' className)* protocols
 className = NAME
 protocols = '<' NAME (',' NAME)* '>' | ''
 
 Extension:
 extension = '@interface' className '(' ')' protocols
 className = NAME
 protocols = '<' NAME (',' NAME)* '>' | ''
 */
class InterfaceGenParser {
    func parse(_ tokens: Tokens) -> [ClassNode] {
        let parser = token(.interface)
        return []
    }
    
//    func className() -> Parser<String> {
//
//    }
//
//    func protocols() -> Parser<[String]> {
//
//    }
}
