//
//  Monad.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

func >>- <T, U>(lhs: Parser<T>, rhs: @escaping (T) -> Parser<U>) -> Parser<U> {
    return lhs.flatMap(rhs)
}

func -<< <T, U>(lhs: @escaping (T) -> Parser<U>, rhs: Parser<T>) -> Parser<U> {
    return rhs.flatMap(lhs)
}

extension Parser {
    func flatMap<U>(_ f: @escaping (T) -> Parser<U>) -> Parser<U> {
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
//            guard let (l, lrest) = self.parse(tokens) else {
//                return nil
//            }
//            let p = f(l)
//            return p.parse(lrest)
            
            switch self.parse(tokens) {
            case .success(let (result, rest)):
                let p = f(result)
                return p.parse(rest)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
