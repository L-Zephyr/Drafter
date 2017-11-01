//
//  Alternative.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

/// 左侧parser成功返回左侧的结果，否则返回右侧parser的结果
func <|> <T>(lhs: Parser<T>, rhs: Parser<T>) -> Parser<T> {
    return lhs.or(rhs)
}

extension Parser {
    func or(_ other: Parser<T>) -> Parser<T> {
        return Parser(parse: { (tokens) -> (T, Tokens)? in
            return self.parse(tokens) ?? other.parse(tokens)
        })
    }
}
