//
//  Parser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

enum ParserError: Error {
    case notMatch(String)
}

protocol Node { } // 语法节点

// TODO: 抽离公共的操作

protocol Parser {
//    func parse() -> Node? // 执行解析，解析失败则抛出相应错误
}

/// 回溯解析器
//class RecallParser: Parser {
//    func parse() throws {
//
//    }
//
//    init(lexer: Lexer) {
//        self.input = lexer
//    }
//
//    var input: Lexer
//    var lookaheads: [Token]
//    var index: Int
//}

