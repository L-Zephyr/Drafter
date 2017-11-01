//
//  Applicative.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

/// 顺序执行两个parser，然后将右侧parser的结果应用到左侧返回的函数中
func <*> <T, U>(lhs: Parser<(T) -> U>, rhs: Parser<T>) -> Parser<U> {
    return rhs.apply(lhs)
}

/// 顺序执行两个parser，最后直接抛弃左侧parser的结果，返回右侧parser的结果
func *> <T, U>(lhs: Parser<T>, rhs: Parser<U>) -> Parser<U> {
    return Parser<U> { (tokens) -> (U, Tokens)? in
        guard let (_, lrest) = lhs.parse(tokens) else {
            return nil
        }
        guard let (r, rrest) = rhs.parse(lrest) else {
            return nil
        }
        return (r, rrest)
    }
}

/// 顺序执行两个parser，最后直接抛弃有侧parser的结果，返回左侧parser的结果
func <* <T, U>(lhs: Parser<T>, rhs: Parser<U>) -> Parser<T> {
    return Parser<T> { (tokens) -> (T, Tokens)? in
        guard let (l, lrest) = lhs.parse(tokens) else {
            return nil
        }
        guard let (_, rrest) = rhs.parse(lrest) else {
            return nil
        }
        return (l, rrest)
    }
}

extension Parser {
    func apply<U>(_ parser: Parser<(T) -> U>) -> Parser<U> {
        return Parser<U> { (tokens) -> (U, Tokens)? in
            guard let (l, lrest) = parser.parse(tokens) else {
                return nil
            }
            guard let (r, rrest) = self.parse(lrest) else {
                return nil
            }
            return (l(r), rrest)
        }
    }
}
