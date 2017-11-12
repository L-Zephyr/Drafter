//
//  SwiftMethodGenParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/10.
//

import Foundation

class SwiftMethodGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [MethodNode] {
        return methodDef.continuous.run(tokens) ?? []
    }

    var parser: Parser<[MethodNode]> {
        return methodDef.continuous
    }
}

/*
 method_definition  = is_static 'func' NAME ‘(' param_list ')' return_type method_body
 param_list         = (param (',' param)*)?
 param              = ('_' | NAME)? NAME ':' param_type default_val
 default_val        = '=' ANY
 method_body        = '{' BODY '}'
 */
extension SwiftMethodGenParser {
    /// 方法定义解析
    /**
     method_definition  = is_static 'func' NAME ‘(' param_list ')' return_type method_body
     */
    var methodDef: Parser<MethodNode> {
        return curry(MethodNode.swiftInit)
            <^> isStatic
            <*> token(.function) *> token(.name) => stringify
            <*> paramList.between(token(.leftParen), token(.rightParen))
            <*> trying(modifier) *> retType
            <*> body
            <*> pure([])
    }

    /// 静态方法
    /**
     ('class' | 'static')
     */
    var isStatic: Parser<Bool> {
        return (token(.cls) <|> token(.statical)) *> pure(true)
            <|> pure(false)
    }

    /// 参数列表
    /**
     param_list = (param (',' param)*)?
     */
    var paramList: Parser<[Param]> {
        // TODO: 像这种两个选项有共同前缀的规则需要优化
        return param.separateBy(token(.comma)) // 多个参数
            <|> { [$0] } <^> param // 单个参数
            <|> pure([]) // 没有参数
    }
    
    /// 参数
    /**
     param = ('_' | NAME)? NAME ':' param_type default_val
     */
    var param: Parser<Param> {
        let outter = token(.underline) *> pure("") // "_ param:"
            <|> lookAhead(token(.name) <* token(.colon)) => stringify // "param:"
            <|> token(.name) => stringify // "outter param:"
        
        return curry(Param.swiftInit)
            <^> trying(modifier) *> outter
            <*> token(.name) <* token(.colon) => stringify
            <*> trying(modifier) *> type <* trying(defaultValue)
    }
    
    /// 解析参数的默认值: "= xx"
    var defaultValue: Parser<[Token]> {
        return token(.equal) *> anyTokens(until: token(.comma) <|> token(.rightParen))
    }

    /// 返回值类型
    /**
     return_type = (-> type)?
     */
    var retType: Parser<String> {
        return lookAhead(token(.rightArrow)) *> token(.rightArrow) *> type
            <|> pure("")
    }
    
    /// 解析一个类型声明
    var type: Parser<String> {
        // 匹配一个独立的类型
        let singleType = token(.name) => stringify // xx
            <|> { $0.joined() } <^> anyEnclosureTokens => stringify // (..)、[..]
        
        return { $0.joined(separator: "->") } <^> singleType.separateBy(token(.rightArrow)) // 函数类型: (xx)->xx...
            <|> singleType // 普通类型: xx
    }

    /// 函数体定义
    var body: Parser<[Token]> {
        return anyTokens(inside: token(.leftBrace), and: token(.rightBrace))
    }
    
    /// 处理swift方法中的修饰符: @autoclosure, inout, rethrow等
    var modifier: Parser<Token> {
        return token(.autoclosure) <|> token(.`inout`) <|> token(.`throw`)
    }
}

extension Param {
    static func swiftInit(_ outter: String, _ inner: String, _ type: String) -> Param {
        return Param(outterName: outter, type: type, innerName: inner)
    }
}

