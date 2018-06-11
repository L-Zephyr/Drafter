//
//  SwiftMethodParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/10.
//

import Foundation
import SwiftyParse

class SwiftMethodParser: ConcreteParserType {
    
    var parser: TokenParser<[MethodNode]> {
        return methodDef.continuous
    }
}

// MARK: - Parser

extension SwiftMethodParser {
    /// 方法定义解析
    /**
     method_definition  = is_static 'func' NAME ‘(' param_list ')' return_type method_body
     */
    var methodDef: TokenParser<MethodNode> {
        return curry(MethodNode.swiftInit)
            <^> isStatic
            <*> methodName
            <*> paramList.between(token(.leftParen), token(.rightParen))
            <*> modifiers *> retType
            <*> ({ SwiftInvokeParser().parser.run($0) ?? [] } <^> body)
    }

    /// 静态方法
    /**
     is_static = ('class' | 'static')
     */
    var isStatic: TokenParser<Bool> {
        return (token(.cls) <|> token(.statical)) *> pure(true)
            <|> pure(false)
    }
    
    /// 方法名
    /**
     method_name = 'func' NAME | 'init`
     */
    var methodName: TokenParser<String> {
        return token(.function) *> token(.name) => stringify
            <|> token(.`init`) *> pure("init")
    }

    /// 参数列表
    /**
     param_list = (param (',' param)*)?
     */
    var paramList: TokenParser<[Param]> {
        return param.sepBy(token(.comma)) // 参数
    }
    
    /// 参数
    /**
     param = ('_' | NAME)? NAME ':' param_type default_val
     */
    var param: TokenParser<Param> {
        let outter = token(.underline) *> pure("") // "_ param:"
            <|> (token(.name) <* token(.colon)).lookahead => stringify // "param:"
            <|> token(.name) => stringify // "outter inner:"
        
        return curry(Param.swiftInit)
            <^> outter
            <*> token(.name) <* token(.colon) => stringify
            <*> modifiers *> type <* defaultValue.try
    }
    
    /// 解析参数的默认值: "= xx"
    var defaultValue: TokenParser<[Token]> {
        return token(.equal) *> anyOpenTokens(until: token(.comma) <|> token(.rightParen))
    }

    /// 返回值类型
    /**
     return_type = (-> type)?
     */
    var retType: TokenParser<String> {
        return token(.rightArrow).lookahead *> token(.rightArrow) *> type
            <|> pure("")
    }
    
    /// 解析一个类型声明
    var type: TokenParser<String> {
        // 泛型
        let generic = anyTokens(inside: token(.leftAngle), and: token(.rightAngle))
        
        // 匹配一个独立的类型
        let singleType =
            anyEnclosedTokens => joinedText // (..)、[..]
            <|> token(.name).sepBy(token(.dot)) <* generic.try => joinedText // xx.xx<T>
        
        return singleType.sepBy(token(.rightArrow)) => joinedText("->") // (xx)->xx...
    }

    /// 函数体定义
    var body: TokenParser<[Token]> {
        return anyTokens(inside: token(.leftBrace), and: token(.rightBrace))
    }
    
    /// 处理swift方法中的修饰符: @autoclosure, inout, rethrow等
    var modifiers: TokenParser<[Token]> {
        return (token(.autoclosure) <|> token(.`inout`) <|> token(.`throw`) <|> token(.escaping)).many
    }
}

extension Param {
    static func swiftInit(_ outter: String, _ inner: String, _ type: String) -> Param {
        return Param(outterName: outter, type: type, innerName: inner)
    }
}

