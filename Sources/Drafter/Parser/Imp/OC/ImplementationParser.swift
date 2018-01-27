//
//  ImplementationParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2018/1/24.
//

import Cocoa

class ImplementationParser: ParserType {
    var parser: Parser<[MethodNode]> {
        return implementation
    }
}

extension ImplementationParser {
    var implementation: Parser<[MethodNode]> {
        return anyTokens(inside: token(.implementation), and: token(.end)).map {
            ObjcMethodParser().parser.run($0) ?? []
        }
    }
}
