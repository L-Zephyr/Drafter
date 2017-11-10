//
//  ObjcMethodParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/11/5.
//

import Foundation

class ObjcMethodParser: ParserType {
    
    func parse(_ tokens: Tokens) -> [MethodNode] {
        let method = methodDefParser <|> methodDeclParser
        return method.continuous.run(tokens) ?? []
    }
}

// MARK: - Parser

extension ObjcMethodParser {
    /// 解析OC方法声明
    /**
     method_decl = is_static type method_selector ';'
     */
    var methodDeclParser: Parser<MethodNode> {
        // TODO: 优化
        return curry(MethodNode.init)(false)
            <^> isStatic 
            <*> type
            <*> pure("")
            <*> methodSelector <* token(.semicolon) // 声明结束
            <*> pure([])
            <*> pure([])
    }
    
    /// 解析OC方法定义
    /**
     method_definition = is_static type method_selector method_body
     */
    var methodDefParser: Parser<MethodNode> {
        return curry(MethodNode.init)(false)
            <^> isStatic
            <*> type
            <*> pure("")
            <*> methodSelector
            <*> body
            <*> pure([])
    }
    
    /// 静态方法
    /**
     ('-' | '+')
     */
    var isStatic: Parser<Bool> {
        return token(.minus).map { _ in false } <|> token(.plus).map { _ in true }
    }
    
    /// 解析类型
    /**
     type = '(' TYPE_NAME ')'
     */
    var type: Parser<String> {
        return curry({ $0.joined(separator: " ") })
            <^> anyToken(between: .leftParen, and: .rightParen) => stringify
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
        return anyToken(between: .leftBrace, and: .rightBrace)
    }
}
