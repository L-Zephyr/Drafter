//
//  TokenLexer.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation

// MARK: - TokenLexer

/// TokenLexer类似于一个代理，仅将Token按顺序返回
class TokenLexer: Lexer {
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    var nextToken: Token {
        if index != tokens.count {
            let token = tokens[index]
            index += 1
            return token
        }
        return Token(type: .endOfFile, text: "")
    }
    
    fileprivate var index: Int = 0
    fileprivate var tokens: [Token] = []
}
