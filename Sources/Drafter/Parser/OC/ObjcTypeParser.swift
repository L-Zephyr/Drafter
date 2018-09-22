//
//  ObjcTypeParser.swift
//  Drafter
//
//  Created by LZephyr on 2018/8/28.
//

import Foundation
import SwiftyParse

/// 解析OC的Interface和Implementation类型
class ObjcTypeParser: ConcreteParserType {
    var parser: TokenParser<[ObjcTypeNode]> {
        return objcType.continuous
    }
}

extension ObjcTypeParser {
    var objcType: TokenParser<ObjcTypeNode> {
        return curry(ObjcTypeNode.interface) <^> InterfaceParser().singleParser
            <|> curry(ObjcTypeNode.implementaion) <^> ImplementationParser().implementation
            <|> curry(ObjcTypeNode.protocol) <^> ObjcProtocolParser().protocol
    }
}
