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

        // v1
//        let parser = curry(ClassNode.init)
//                <^> (token(.interface) *> token(.name)).map({ $0.text })
//                <*> (curry(ClassNode.init(clsName:)) <^> (curry({ $0.text }) <^> token(.colon) *> token(.name))
//                <*> token(.name).separateBy(token(.comma)).between(l, r).map({ $0.map { $0.text } })
        
        // @interface xxx : xxx <xx, xx>
        let parser = curry(ClassNode.init)
            <^> token(.interface) *> token(.name) => stringify
            <*> (curry(ClassNode.init(clsName:)) <^> token(.colon) *> token(.name) => stringify)
            <*> token(.name).separateBy(token(.comma)).between(l, r) => stringify
        
        switch parser.parse(tokens) {
        case .success(let (result, rest)):
            return [result]
        case .failure(let error):
            print("\(error)")
            return []
        }
    }
}
