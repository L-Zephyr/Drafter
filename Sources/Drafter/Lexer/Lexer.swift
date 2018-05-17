//
//  Lexer.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

enum LexerError: Error {
    case notMatch
}

protocol Lexer {
    var nextToken: Token { get } // 获取Token
}

extension Lexer {
    /// 获取所有的Token
    var allTokens: [Token] {
        var result = [Token]()
        var next = self.nextToken
        
        while next.type != .endOfFile {
            result.append(next)
            next = self.nextToken
        }
        return result
    }
}
