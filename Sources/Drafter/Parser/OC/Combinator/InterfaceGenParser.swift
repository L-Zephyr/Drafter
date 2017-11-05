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
        // @interface xxx : xxx <xx, xx>
        let parser = categoryParser <|> classParser
        
        switch parser.parse(tokens) {
        case .success(let (result, _)):
            return [result]
        case .failure(let error):
            print("\(error)")
            return []
        }
    }
    
    // v1
//    let parser = curry(ClassNode.init)
//            <^> (token(.interface) *> token(.name)).map({ $0.text })
//            <*> (curry(ClassNode.init(clsName:)) <^> (curry({ $0.text }) <^> token(.colon) *> token(.name))
//            <*> token(.name).separateBy(token(.comma)).between(l, r).map({ $0.map { $0.text } })
    
    /// 解析类型定义
    var classParser: Parser<ClassNode> {
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx : xx <xx, xx>
        let parser = curry(ClassNode.init)
            <^> token(.interface) *> token(.name) => stringify
            <*> trying(token(.colon) *> token(.name)) => toClassNode
            <*> trying(token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) => stringify
        return parser
    }
    
    /// 解析分类定义
    var categoryParser: Parser<ClassNode> {
        let lParen = token(.leftParen)
        let rParen = token(.rightParen)
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        
        // @interface xx(xx?) <xx, xx>
        return curry(ClassNode.init)
            <^> token(.interface) *> token(.name) => stringify
            <*> trying(token(.name)).between(lParen, rParen) *> pure(nil) // 分类的名字是可选项, 忽略结果
            <*> trying(token(.name).separateBy(token(.comma)).between(lAngle, rAngle)) => stringify
    }
    
    /// 将一个Token转换成ClassNode类型
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
