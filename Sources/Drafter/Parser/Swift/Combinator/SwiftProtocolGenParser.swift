//
//  SwiftProtocolGenParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/9.
//

import Foundation

class SwiftProtocolGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [ProtocolNode] {
        return protocolParser.continuous.run(tokens) ?? []
    }
    
    var parser: Parser<[ProtocolNode]> {
        return protocolParser.continuous
    }
}

// MARK: - SwiftProtocolGenParser

extension SwiftProtocolGenParser {
    /// 解析一个协议定义
    /**
     protocol_definition = 'protocol' NAME inherit_list?
     */
    var protocolParser: Parser<ProtocolNode> {
        return curry(ProtocolNode.init)
            <^> token(.proto) *> token(.name) => stringify
            <*> inheritList
    }
    
    /// 解析协议的继承列表
    /**
     inherit_list = ':' NAME (',' NAME)*
     */
    var inheritList: Parser<[String]> {
        return token(.colon) *> token(.name).separateBy(token(.comma)) => stringify
    }
}
