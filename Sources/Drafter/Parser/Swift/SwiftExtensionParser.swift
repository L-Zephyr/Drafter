//
//  SwiftExtensionParser.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/27.
//

import Foundation

/// 解析Swift的Extension
class SwiftExtensionParser: ConcreteParserType {
    var parser: TokenParser<[ExtensionNode]> {
        return extensionParser.continuous
    }
}

extension SwiftExtensionParser {
    /**
     解析swift的extension
     extension_definition = 'extension' NAME (':' protocols)? condition extension_body
     */
    var extensionParser: TokenParser<ExtensionNode> {
        return curry(ExtensionNode.init)
            <^> token(.name) => stringify
            <*> (token(.colon) *> protocols).try => stringify
            <*> condition *> extensionBody
    }
    
//    /// 解析一个类型的名称(可能带有泛型限定)
//    var variable: TokenParser<String> {
//        return
//    }
    
    /**
     协议列表
     protocols = NAME (',' NAME)*
     */
    var protocols: TokenParser<[Token]> {
        return token(.name).sepBy(token(.comma))
    }
    
    /**
     可能存在where语句的限定符, 直接忽略
     */
    var condition: TokenParser<String> {
        return anyTokens(until: token(.leftBrace)) *> pure("")
    }
    
    /**
     解析方法定义
     extension_body = '{' METHODS '}'
     */
    var extensionBody: TokenParser<[MethodNode]> {
        return anyTokens(inside: token(.leftBrace), and: token(.rightBrace))
            .map {
                SwiftMethodParser().parser.run($0) ?? []
            }
    }
    
}


