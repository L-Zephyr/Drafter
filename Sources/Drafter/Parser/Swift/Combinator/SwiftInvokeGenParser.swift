//
//  SwiftInvokeGenParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/11/12.
//

import Foundation

class SwiftInvokeGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [MethodInvokeNode] {
        return methodInvoke.continuous.run(tokens) ?? []
    }
    
    var parser: Parser<[MethodInvokeNode]> {
        return methodInvoke.continuous
    }
}

// MARK: - Parser

/*
 method_invoke  = NAME '(' param_list? ')' callee?
 callee         = ('?' | '!')? '.' (method_invoke | NAME)
 param_list     = param (param ',')*
 param          = ...
 
 
 method_invoke = (invoker '.')? NAME '(' param_list? ')'
 invoker = NAME | method_invoke
 param_list     = param (param ',')*
 */
extension SwiftInvokeGenParser {
    
    /// method_invoke = single_method ('.' single_method)
    var methodInvoke: Parser<MethodInvokeNode> {
        let methodSequence = singleMethod
            .separateBy(token(.dot))
            .map({ (methods) -> MethodInvokeNode in
                methods.dropFirst().reduce(methods[0]) { (last, current) in
                    current.invoker = .method(last)
                    return current
                }
            })
        
        return methodSequence <|> singleMethod
    }
    
    /// 匹配一个单独的方法
    /// single_method = (invoker '.')? NAME '(' param_list? ')'
    var singleMethod: Parser<MethodInvokeNode> {
        return curry(MethodInvokeNode.swiftInit)
            <^> token(.name) => stringify // 方法名
            <*> paramList.between(token(.leftParen), token(.rightParen)) // 参数列表
    }
    
    /// NAME ('.' NAME)*
//    var nameInvoker: Parser<MethodInvoker> {
//        return { .name($0.joinedText(separator: ".")) }
//            <^> token(.name)
//            .notFollowedBy( token(.leftParen) <|> token(.leftBrace) )
//            .separateBy( token(.dot) )
//    }
    
    /// param_list = param (param ',')*
    var paramList: Parser<[String]> {
        return param.separateBy(token(.comma))
            <|> { [$0] } <^> param
            <|> pure([])
    }
    
    /// param =  (NAME ':')? param_body
    var param: Parser<String> {
        return { $0?.text ?? "" }
            <^> not(token(.rightParen)) *> trying(token(.name) <* token(.colon))
            <* (anyEnclosureTokens <|> anyTokens(until: token(.comma) <|> token(.rightParen)))
    }
    
//    var paramBody: Parser<[]> {
//
//    }
}

extension MethodInvokeNode {
    static func swiftInit(methodName: String, _ params: [String]) -> MethodInvokeNode {
        let invoke = MethodInvokeNode()
        invoke.isSwift = true
        invoke.params = params
        invoke.methodName = methodName
        return invoke
    }
}
