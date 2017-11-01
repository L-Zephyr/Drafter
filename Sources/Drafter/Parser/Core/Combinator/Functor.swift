//
//  Functor.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

func <^> <T, U>(f: @escaping (T) -> U, p: Parser<T>) -> Parser<U> {
    return p.map(f)
}

extension Parser {
    func map<U>(_ f: @escaping (T) -> U) -> Parser<U> {
        return Parser<U> { (tokens) -> (U, Tokens)? in
            guard let (result, rest) = self.parse(tokens) else {
                return nil
            }
            return (f(result), rest)
        }
    }
}
