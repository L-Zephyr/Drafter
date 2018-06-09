//
//  Functor.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

public func <^> <T, Stream, U>(f: @escaping (T) -> U, p: Parser<T, Stream>) -> Parser<U, Stream> {
    return p.map(f)
}

public extension Parser {
    func map<U>(_ f: @escaping (Token) -> U) -> Parser<U, Stream> {
        return Parser<U, Stream>(parse: { (stream) -> ParseResult<(U, Stream)> in
            switch self.parse(stream) {
            case .success(let (r, remain)):
                return .success((f(r), remain))
            case .failure(let error):
                return .failure(error)
            }
        })
    }
}
