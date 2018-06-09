//
//  Applicative.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 顺序执行两个parser，然后将右侧parser的结果应用到左侧返回的函数中
public func <*> <T, U, S>(lhs: Parser<(T) -> U, S>, rhs: Parser<T, S>) -> Parser<U, S> {
    return rhs.apply(lhs)
}

/// 顺序执行两个parser，最后直接抛弃左侧parser的结果，返回右侧parser的结果
public func *> <T, U, S>(lhs: Parser<T, S>, rhs: Parser<U, S>) -> Parser<U, S> {
    return Parser<U, S> { (tokens) -> ParseResult<(U, S)> in
        let lresult = lhs.parse(tokens)
        guard let l = lresult.value else {
            return .failure(lresult.error!)
        }
        
        let rresult = rhs.parse(l.1)
        guard let r = rresult.value else {
            return .failure(rresult.error!)
        }
        
        return .success(r)
    }
}

/// 顺序执行两个parser，最后直接抛弃有侧parser的结果，返回左侧parser的结果
public func <* <T, U, S>(lhs: Parser<T, S>, rhs: Parser<U, S>) -> Parser<T, S> {
    return Parser<T, S> { (tokens) -> ParseResult<(T, S)> in
        let lresult = lhs.parse(tokens)
        guard let l = lresult.value else {
            return .failure(lresult.error!)
        }
        
        let rresult = rhs.parse(l.1)
        guard let r = rresult.value else {
            return .failure(rresult.error!)
        }
        
        return .success((l.0, r.1))
    }
}

public extension Parser {
    func apply<U>(_ parser: Parser<(Token) -> U, Stream>) -> Parser<U, Stream> {
        return Parser<U, Stream> { (stream) -> ParseResult<(U, Stream)> in
            let lresult = parser.parse(stream)
            guard let l = lresult.value else {
                return .failure(lresult.error!)
            }
            
            let rresult = self.parse(l.1)
            guard let r = rresult.value else {
                return .failure(rresult.error!)
            }
            
            return .success((l.0(r.0), r.1))
        }
    }
}
