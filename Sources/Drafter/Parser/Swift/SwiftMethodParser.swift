//
//  SwiftMethodParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/10.
//

import Foundation

class SwiftMethodParser: ParserType {
    
    var parser: Parser<[MethodNode]> {
        return methodDef.continuous
    }
}

// MARK: - Parser

extension SwiftMethodParser {
    /// 方法定义解析
    /**
     method_definition  = is_static 'func' NAME ‘(' param_list ')' return_type method_body
     */
    var methodDef: Parser<MethodNode> {
        return curry(MethodNode.swiftInit)
            <^> isStatic
            <*> methodName
            <*> paramList.between(token(.leftParen), token(.rightParen))
            <*> trying(modifier) *> retType
            <*> ({ SwiftInvokeParser().parser.run($0) ?? [] } <^> body)
    }

    /// 静态方法
    /**
     is_static = ('class' | 'static')
     */
    var isStatic: Parser<Bool> {
        return (token(.cls) <|> token(.statical)) *> pure(true)
            <|> pure(false)
    }
    
    /// 方法名
    /**
     method_name = 'func' NAME | 'init`
     */
    var methodName: Parser<String> {
        return token(.function) *> token(.name) => stringify
            <|> token(.`init`) *> pure("init")
    }

    /// 参数列表
    /**
     param_list = (param (',' param)*)?
     */
    var paramList: Parser<[Param]> {
        return param.separateBy(token(.comma)) // 参数
    }
    
    /// 参数
    /**
     param = ('_' | NAME)? NAME ':' param_type default_val
     */
    var param: Parser<Param> {
        let outter = token(.underline) *> pure("") // "_ param:"
            <|> lookAhead(token(.name) <* token(.colon)) => stringify // "param:"
            <|> token(.name) => stringify // "outter inner:"
        
        return curry(Param.swiftInit)
            <^> outter
            <*> token(.name) <* token(.colon) => stringify
            <*> trying(modifier) *> type <* trying(defaultValue)
    }
    
    /// 解析参数的默认值: "= xx"
    var defaultValue: Parser<[Token]> {
        return token(.equal) *> anyOpenTokens(until: token(.comma) <|> token(.rightParen))
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
        // 泛型
        let generic = anyTokens(inside: token(.leftAngle), and: token(.rightAngle))
        
        // 匹配一个独立的类型
        let singleType =
            anyEnclosedTokens => joinedText // (..)、[..]
            <|> token(.name).separateBy(token(.dot)) <* trying(generic) => joinedText // xx.xx<T>
        
        return singleType.separateBy(token(.rightArrow)) => joinedText("->") // (xx)->xx...
    }

    /// 函数体定义
    var body: Parser<[Token]> {
        return anyTokens(inside: token(.leftBrace), and: token(.rightBrace))
    }
    
    /// 处理swift方法中的修饰符: @autoclosure, inout, rethrow等
    var modifier: Parser<[Token]> {
        return ( token(.autoclosure) <|> token(.`inout`) <|> token(.`throw`) <|> token(.escaping) ).many
    }
}

extension Param {
    static func swiftInit(_ outter: String, _ inner: String, _ type: String) -> Param {
        return Param(outterName: outter, type: type, innerName: inner)
    }
}

