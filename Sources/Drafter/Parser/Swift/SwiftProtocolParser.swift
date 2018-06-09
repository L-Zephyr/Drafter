//
//  SwiftProtocolParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

class SwiftProtocolParser: ConcreteParserType {
    var parser: TokenParser<[ProtocolNode]> {
        return protocolParser.continuous
    }
}

// MARK: - SwiftProtocolParser

extension SwiftProtocolParser {
    /// 解析一个协议定义
    /**
     protocol_definition = 'protocol' NAME inherit_list?
     */
    var protocolParser: TokenParser<ProtocolNode> {
        return curry(ProtocolNode.init)
            <^> token(.proto) *> token(.name) => stringify
            <*> inheritList.try <* token(.leftBrace)
    }
    
    /// 解析协议的继承列表
    /**
     inherit_list = ':' NAME (',' NAME)*
     */
    var inheritList: TokenParser<[String]> {
        return token(.colon) *> token(.name).separateBy(token(.comma)) => stringify
    }
}
