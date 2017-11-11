//
//  ObjcMessageParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/8.
//

import Foundation

class ObjcMessageParser: ParserType {
    func parse(_ tokens: Tokens) -> [MethodInvokeNode] {
        return messageSend.continuous.run(tokens) ?? []
    }
    
    var parser: Parser<[MethodInvokeNode]> {
        return messageSend.continuous
    }
}

// MARK: - Parser

extension ObjcMessageParser {
    
    /// 解析一个方法调用
    /**
     message_send = '[' receiver param_selector ']'
     */
    var messageSend: Parser<MethodInvokeNode> {
        let msg = curry(MethodInvokeNode.init)(false)
            <^> receiver
            <*> pure("")
            <*> paramSelector
        
        return msg.between(token(.leftSquare), token(.rightSquare)) <?> "message_send解析失败"
    }
    
    /// 调用方
    /**
     receiver = message_send | NAME
     */
    var receiver: Parser<MethodInvoker> {
        return toMethodInvoker() <^> lazy(self.messageSend)
            <|> toMethodInvoker() <^> token(.name)
            <?> "receiver解析失败"
    }
    
    /// 参数列表
    /**
     param_selector = param_list | NAME
     */
    var paramSelector: Parser<[String]> {
        return paramList
            <|> curry({ [$0.text] }) <^> token(.name)
            <?> "param_selector解析失败"
    }
    
    /// 带具体参数的列表
    /**
     param_list = (NAME ':' param)+
     */
    var paramList: Parser<[String]> {
        let paramPair = stringify <^> token(.name) <* token(.colon) <* param
        return paramPair.many <?> "param_list解析失败"
    }
    
    /// 解析具体参数内容，参数中的方法调用也解析出来
    // FIXME: 处理这种类型的表达式“[self method] + [self method]”
    var param: Parser<[MethodInvokeNode]> {
        // 处理block定义中的方法调用
        let block = { lazy(self.messageSend).continuous.run($0) ?? [] }
            <^> token(.caret) // ^ 表示block开始
            *> anyTokens(until: token(.leftBrace))
            *> anyTokens(inside: token(.leftBrace), and: token(.rightBrace)) // 匹配block中的所有token
        
        return block // block
            <|> curry({ [$0] }) <^> lazy(self.messageSend) // 方法调用
            <|> anyTokens(until: token(.rightSquare) <|> token(.name) *> token(.colon)) *> pure([]) // 其他直接忽略
            <?> "param解析失败"
    }
}

// MARK: - Helper

extension ObjcMessageParser {
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
