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
        let l = token(.leftAngle)
        let r = token(.rightAngle)
        
        let parser = curry(ClassNode.init)
            <^> (curry(ClassNode.init(clsName:)) <^> (curry({ $0.text }) <^> token(.interface) *> token(.name)))
            <*> (token(.colon) *> token(.name)).map({ $0.text })
            <*> token(.name).separateBy(token(.comma)).between(l, r).map({ $0.map { $0.text } })
        
        switch parser.parse(tokens) {
        case .success(let (result, rest)):
            return [result]
        case .failure(let error):
            print("\(error)")
            return []
        }
    }
}
