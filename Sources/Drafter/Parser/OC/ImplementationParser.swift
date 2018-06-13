//
//  ImplementationParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2018/1/24.
//

import Cocoa
import SwiftyParse

class ImplementationParser: ConcreteParserType {
    var parser: TokenParser<[ImplementationNode]> {
        return implementation.continuous
    }
}

extension ImplementationParser {
    var implementation: TokenParser<ImplementationNode> {
        return curry(ImplementationNode.init)
            <^> token(.implementation) *> token(.name) => stringify
            <*> anyTokens(until: token(.end)).map { ObjcMethodParser().parser.run($0) ?? [] }
    }
}
