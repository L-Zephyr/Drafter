//
//  SwiftMethodGenParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/10.
//

import Foundation

class SwiftMethodGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [MethodNode] {
        return []
    }
    
//    var parser: Parser<[MethodNode]> {
//
//    }
}

/*
 method_definition  = is_static 'func' NAME ‘(' param_list ')' return_type method_body
 param_list         = (param (',' param)*)?
 param              = ('_' | NAME)? NAME ':' param_type
 param_type         = ANY
 return_type        = (-> ANY)?
 method_body        = '{' BODY '}'
 */
extension SwiftMethodGenParser {
//    var methodDef: Parser<MethodNode> {
//        return curry(MethodNode.init)(true)
//            <^> isStatic
//            <*>
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
}
