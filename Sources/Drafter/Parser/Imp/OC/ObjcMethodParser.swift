//
//  ObjcMethodParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/11/5.
//

import Foundation

class ObjcMethodParser: ParserType {
    var parser: Parser<[MethodNode]> {
        return (methodDefParser <|> methodDeclParser).continuous
    }
}

// MARK: - Parser

extension ObjcMethodParser {
    /// 解析OC方法声明
    /**
     method_decl = is_static type method_selector ';'
     */
    var methodDeclParser: Parser<MethodNode> {
        return curry(MethodNode.ocInit)
            <^> isStatic 
            <*> type
            <*> methodSelector <* token(.semicolon) // 声明结束
            <*> pure([])
    }
    
    /// 解析OC方法定义
    /**
     method_definition = is_static type method_selector method_body
     */
    var methodDefParser: Parser<MethodNode> {
        return curry(MethodNode.ocInit)
            <^> isStatic
            <*> type
            <*> methodSelector
            <*> ({ ObjcMessageParser().parser.run($0) ?? [] } <^> body)
    }
    
    /// 静态方法
    /**
     ('-' | '+')
     */
    var isStatic: Parser<Bool> {
        return token(.minus) *> pure(false)
            <|> token(.plus) *> pure(true)
    }
    
    /// 解析类型
    /**
     type = '(' TYPE_NAME ')'
     */
    var type: Parser<String> {
        return anyTokens(inside: token(.leftParen), and: token(.rightParen)) => joinedText(" ")
    }
    
    /// 选择子
    /**
     method_selector   = NAME | method_param_list
     */
    var methodSelector: Parser<[Param]> {
        return paramList
            <|> curry({ [Param(outterName: $0.text, type: "", innerName: "")] }) <^> token(.name)
    }
    
    /// 解析参数列表
    /**
     method_param_list = (NAME ':' type NAME)+
     */
    var paramList: Parser<[Param]> {
        let param = curry(Param.init)
                    <^> token(.name) <* token(.colon) => stringify
                    <*> type
                    <*> token(.name) => stringify
        return param.many
    }
    
    /// 函数体
    /**
     method_body = '{' BODY '}'
     */
    var body: Parser<[Token]> {
        return anyTokens(inside: token(.leftBrace), and: token(.rightBrace))
    }
}
