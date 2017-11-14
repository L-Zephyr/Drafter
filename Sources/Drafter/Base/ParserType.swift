//
//  Parser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

enum ParserError: Error {
    case missMatch(String)
    case custom(String)
    case unknown
}

protocol Node { } // AST节点

protocol ParserType {
    associatedtype T
    var parser: Parser<T> { get }
}

