//
//  ObjcMessageParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/8.
//

import Foundation

class ObjcMessageParser: ParserType {
    
    var parser: Parser<[MethodInvokeNode]> {
        return messageSend.continuous.map({ (methods) -> [MethodInvokeNode] in
            var result = methods
            for method in methods {
                result.append(contentsOf: method.params.reduce([]) { $0 + $1.invokes })
            }
            return result
        })
    }
}

// MARK: - Parser

extension ObjcMessageParser {
    
    /// 解析一个方法调用
    /**
     message_send = '[' receiver param_selector ']'
     */
    var messageSend: Parser<MethodInvokeNode> {
        let msg = curry(MethodInvokeNode.ocInit)
            <^> receiver
            <*> paramSelector
        
        return msg.between(token(.leftSquare), token(.rightSquare)) <?> "message_send解析失败"
    }
    
    /// 调用方
    /**
     receiver = message_send | NAME
     */
    var receiver: Parser<MethodInvoker> {
        return  lazy(self.messageSend) => toMethodInvoker()
            <|> token(.name) => toMethodInvoker()
            <?> "receiver解析失败"
    }
    
    /// 参数列表
    /**
     param_selector = param_list | NAME
     */
    var paramSelector: Parser<[InvokeParam]> {
        return paramList
            <|> { [InvokeParam(name: $0.text, invokes: [])] } <^> token(.name)
            <?> "param_selector解析失败"
    }
    
    /// 带具体参数的列表
    /**
     param_list = (param)+
     */
    var paramList: Parser<[InvokeParam]> {
        return param.many <?> "param_list解析失败"
    }
    
    /// 参数
    /**
     param = NAME ':' param_body
     */
    var param: Parser<InvokeParam> {
        return curry(InvokeParam.init)
            <^> (curry({ "\($0.text)\($1.text)" }) <^> token(.name) <*> token(.colon))
            <*> paramBody
    }
    
    /// 解析具体参数内容，参数中的方法调用也解析出来
    // FIXME: 处理这种类型的表达式“[self method] + [self method]”
    var paramBody: Parser<[MethodInvokeNode]> {
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

extension MethodInvokeNode {
    static func ocInit(_ invoker: MethodInvoker, _ params: [InvokeParam]) -> MethodInvokeNode {
        let invoke = MethodInvokeNode()
        invoke.isSwift = false
        invoke.invoker = invoker
        invoke.params = params
        return invoke
    }
}
