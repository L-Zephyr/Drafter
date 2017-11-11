////
////  SwiftMethodGenParser.swift
////  drafterPackageDescription
////
////  Created by LZephyr on 2017/11/10.
////
//
//import Foundation
//
//class SwiftMethodGenParser: ParserType {
//    func parse(_ tokens: Tokens) -> [MethodNode] {
//        return []
//    }
//
////    var parser: Parser<[MethodNode]> {
////
////    }
//}
//
///*
// method_definition  = is_static 'func' NAME ‘(' param_list ')' return_type method_body
// param_list         = (param (',' param)*)?
// param              = ('_' | NAME)? NAME ':' param_type default_val
// default_val        = '=' ANY
// method_body        = '{' BODY '}'
// */
//extension SwiftMethodGenParser {
//    /// 方法定义解析
//    /**
//     method_definition  = is_static 'func' NAME ‘(' param_list ')' return_type method_body
//     */
//    var methodDef: Parser<MethodNode> {
//        return curry(MethodNode.swiftInit)
//            <^> isStatic
//            <*> token(.function) *> token(.name) => stringify
//            <*> paramList.between(token(.leftParen), token(.rightParen))
//            <*> retType
//            <*> body
//            <*> pure([])
//    }
//
//    /// 静态方法
//    /**
//     ('class' | 'static')
//     */
//    var isStatic: Parser<Bool> {
//        return (token(.cls) <|> token(.statical)) *> pure(true)
//            <|> pure(false)
//    }
//
//    /// 参数列表
//    /**
//     param_list = (param (',' param)*)?
//     */
//    var paramList: Parser<[Param]> {
//        // TODO: 像这种两个选项有共同前缀的规则需要优化
//        return param.separateBy(token(.comma))
//            <|> { [$0] } <^> param
//            <|> pure([])
//    }
//
//    /// 返回值类型
//    /**
//     return_type = (-> ANY)?
//     */
//    var retType: Parser<String> {
//        return { $0.joined() }
//            <^> token(.rightArrow) *> anyTokens(until: token(.leftBrace)) => stringify
//            <|> pure("")
//    }
//
//    /// 函数体定义
//    var body: Parser<[Token]> {
//        return anyTokens(between: .leftBrace, and: .rightBrace)
//    }
//
//    // MARK: - 参数
//
//    /// 参数
//    /**
//     param = ('_' | NAME)? NAME ':' param_type default_val
//     */
//    var param: Parser<Param> {
//        return curry(Param.swiftInit)
//            <^> paramName
//            <*> paramType <* trying(defaultValue)
//    }
//
//    /// 返回值：(outterName, innerName)
//    var paramName: Parser<(String, String)> {
//        let outter = token(.underline) *> pure("") // "_ param:"
//            <|> lookAhead(token(.name) <* token(.colon)) => stringify // "param:"
//            <|> token(.name) => stringify // "outter param:"
//
//        return curry({ ($0, $1) })
//            <^> outter
//            <*> token(.name) <* token(.colon) => stringify
//    }
//
//    var paramType: Parser<String> {
//        return anyTokens(untile: token(.comma))
//    }
//
//    /// 解析参数的默认值
//    var defaultValue: Parser<String> {
//        return token(.equal) *>
//    }
//}
//
//// MARK: - 类型解析
//
//extension SwiftMethodGenParser {
//    var type: Parser<String> {
//        let singleType = token(.name) => stringify // xx
//            <|> { "(\($0.joined())" } <^> token(.leftParen) *> anyEnclosedTokens() => stringify // (...)
//
//        return singleType
//    }
//}
//
//extension Param {
//    static func swiftInit(_ paramName: (String, String), _ type: String) -> Param {
//        return Param(outterName: paramName.0, type: type, innerName: paramName.1)
//    }
//}

