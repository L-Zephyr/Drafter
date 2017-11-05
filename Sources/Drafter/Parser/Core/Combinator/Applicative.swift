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
    return Parser<U> { (tokens) -> Result<(U, Tokens)> in
//        guard let (_, lrest) = lhs.parse(tokens) else {
//            return nil
//        }
//        guard let (r, rrest) = rhs.parse(lrest) else {
//            return nil
//        }
//        return (r, rrest)
        
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
func <* <T, U>(lhs: Parser<T>, rhs: Parser<U>) -> Parser<T> {
    return Parser<T> { (tokens) -> Result<(T, Tokens)> in
//        guard let (l, lrest) = lhs.parse(tokens) else {
//            return nil
//        }
//        guard let (_, rrest) = rhs.parse(lrest) else {
//            return nil
//        }
//        return (l, rrest)
        
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

extension Parser {
    func apply<U>(_ parser: Parser<(T) -> U>) -> Parser<U> {
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
//            guard let (l, lrest) = parser.parse(tokens) else {
//                return nil
//            }
//            guard let (r, rrest) = self.parse(lrest) else {
//                return nil
//            }
//            return (l(r), rrest)
            let lresult = parser.parse(tokens)
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
