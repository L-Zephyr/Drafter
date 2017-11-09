//
//  ObjcMessageGenParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/8.
//

import Foundation

class ObjcMessageGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [MethodInvokeNode] {
        return messageSend.continuous.run(tokens) ?? []
    }
    
    var parser: Parser<[MethodInvokeNode]> {
        return messageSend.continuous
    }
}

// MARK: - Parser

/*
 statement    = message_send ';'
 param        = ...
 */
extension ObjcMessageGenParser {
    
    /// 解析一个方法调用
    /**
     message_send = '[' receiver param_selector ']'
     */
    var messageSend: Parser<MethodInvokeNode> {
        let msg = curry(MethodInvokeNode.init)(false)
            <^> receiver
            <*> pure("")
            <*> paramSelector
        return msg.between(token(.leftSquare), token(.rightSquare))
    }
    
    /// 调用方
    /**
     receiver = message_send | NAME
     */
    var receiver: Parser<MethodInvoker> {
        return toMethodInvoker() <^> lazy(self.messageSend)
            <|> toMethodInvoker() <^> token(.name)
    }
    
    /// 参数列表
    /**
     param_selector = param_list | NAME
     */
    var paramSelector: Parser<[String]> {
        return paramList
            <|> curry({ [$0.text] }) <^> token(.name)
    }
    
    /// 带具体参数的列表
    /**
     param_list = (NAME ':' param)+
     */
    var paramList: Parser<[String]> {
        let paramPair = stringify <^> token(.name) <* token(.colon) <* param
        return paramPair.many
    }
    
    /// 参数内容，需要解析参数中的方法调用
    var param: Parser<[MethodInvokeNode]> {
//        return token(.caret) *> pure([]) // 匿名block
//            <|> curry({ [$0] }) <^> lazy(self.messageSend) // 方法调用
//            <|> anyToken(until: token(.rightSquare) <|> token(.name) *> token(.colon)) *> pure([]) // 其他直接忽略
        return curry({ [$0] }) <^> lazy(self.messageSend)
    }
}

// MARK: - Helper

extension ObjcMessageGenParser {
    func toMethodInvoker() -> (MethodInvokeNode) -> MethodInvoker {
        return { invoke in
            .method(invoke)
        }
    }
    
    func toMethodInvoker() -> (Token) -> MethodInvoker {
        return { token in
            .name(token.text)
        }
    }
}
