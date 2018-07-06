//
//  SwiftTypeParser.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/7/5.
//

import Foundation
import SwiftyParse

class SwiftTypeParser: ConcreteParserType {
    /// 解析所有的自定义Swift类型
    var parser: TokenParser<[SwiftTypeNode]> {
        return swiftType.continuous
    }
}

fileprivate extension SwiftTypeParser {
    var swiftType: TokenParser<SwiftTypeNode> {
        return curry(SwiftTypeNode.class) <^> SwiftClassParser().classParser
            <|> curry(SwiftTypeNode.extension) <^> SwiftExtensionParser().extensionParser
            <|> curry(SwiftTypeNode.protocol) <^> SwiftProtocolParser().protocolParser
    }
}
