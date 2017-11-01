//
//  ParserType.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

typealias Tokens = [Token]

struct Parser<T> {
    var parse: (Tokens) -> (T, Tokens)?
}

/// 创建一个不消耗任何输入，直接返回给定值的Parser
func pure<T>(_ t: T) -> Parser<T> {
    return Parser(parse: { (tokens) -> (T, Tokens)? in
        return (t, tokens)
    })
}

/// 创建一个始终返回错误的parser
func fail<T>() -> Parser<T> {
    return Parser(parse: { (tokens) -> (T, Tokens)? in
        return nil
    })
}

/// 创建解析单个token的parser
func token(_ t: TokenType) -> Parser<Token> {
    return Parser(parse: { (tokens) -> (Token, Tokens)? in
        guard let first = tokens.first, first.type == t else {
            return nil
        }
        return (first, Array(tokens.dropFirst()))
    })
}
