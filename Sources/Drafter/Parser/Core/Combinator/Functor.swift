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
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
            let r = self.parse(tokens)
            switch r {
            case .success(let (result, rest)):
                return .success((f(result), rest))
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
