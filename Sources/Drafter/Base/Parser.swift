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

protocol Node { } // AST节点

protocol Parser {
	func parse() -> [Node]
}

extension Parser {
    func parse() -> [Node] {
        return []
    }
}

// MARK: - BacktrackParser

/// LL(k) parser
class BacktrackParser: Parser {
    
    // MARK: - 初始化方法
    
    init(lexer: Lexer) {
        self.input = lexer
    }
    
    var input: Lexer
    var lookaheads: [Token] = []
    var currentIndex: Int = 0
    var marks: [Int] = []
    
    /// 返回从当前位置开始第n个Token
    func token(at index: Int = 0) -> Token {
        sync(index + 1) // 保证index位置有有效的Token
        return lookaheads[currentIndex + index]
    }
    
    /// 在当前位置匹配指定Token, 返回匹配成功的Token
    @discardableResult
    func match(_ t: TokenType) throws -> Token {
        if token().type != t {
            throw ParserError.notMatch("Expected: \(t), found: \(token().type)")
        }
        let tok = token()
        consume()
        
        return tok
    }
    
    // MARK: - 步进
    
    func consume(step: Int = 1) {
        currentIndex += step
        
        // 不在推演状态，且到达了lookaheads缓冲区最后一位则清空lookaheads
        if currentIndex == lookaheads.count && !isSpeculating {
            currentIndex = 0
            lookaheads.removeAll()
        }
        sync(step)
    }
    
    /// 保证从当前位置开始直到count都有有效的Token, count从1开始
    func sync(_ count: Int) {
        if currentIndex + count > lookaheads.count {
            // 不足则读取相应数量的Token
            for _ in 0..<count {
                lookaheads.append(input.nextToken)
            }
        }
    }
    
    // MARK: - 推演方法
    
    /// 开始推演之前调用mark
    func mark() {
        marks.append(currentIndex)
    }
    
    /// 推演结束后调用release
    func release() {
        if let index = marks.last {
            marks.removeLast()
            currentIndex = index
        }
    }
    
    /// 是否正在进行推演
    var isSpeculating: Bool {
        return marks.count != 0
    }
}

