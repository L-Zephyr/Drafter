//
//  Extensions.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

extension Parser {
    
    /// 多次重复该parser直到失败为止，将结果保存在数组中返回，如果结果数组为空则返回错误
    var many: Parser<[T]> {
        return Parser<[T]> { (tokens) -> Result<([T], Tokens)> in
            var result = [T]()
            var remainder = tokens
            while true {
                switch self.parse(remainder) {
                case .success(let (r, rest)):
                    result.append(r)
                    remainder = rest
                case .failure(let error):
                    if result.count == 0 {
                        return .failure(error)
                    } else {
                        #if DEBUG
                            print("many parse stop: \(error)")
                        #endif
                        return .success((result, remainder))
                    }
                }
            }
        }
    }
    
    /// 尝试解析多个由指定标签分隔的值，返回结果的集合，集合为空则返回错误
    func separateBy<U>(_ p: Parser<U>) -> Parser<[T]> {
        return curry({ $0 + [$1] }) <^> (self <* p).many <*> self
            <|> { [$0] } <^> self
    }
    
    /// 解析包含在指定标签之间的值: p self p
    func between<A, B>(_ left: Parser<A>, _ right: Parser<B>) -> Parser<T> {
        return left *> self <* right
    }
    
    /// 仅当self成功，other失败时才会返回成功，other不会消耗任何输入
    func notFollowedBy<U>(_ other: Parser<U>) -> Parser<T> {
        return self.flatMap { result in
            Parser<T> { (tokens) -> Result<(T, Tokens)> in
                if case .failure(_) = other.parse(tokens) { // other失败才会返回成功
                    return .success((result, tokens))
                } else {
                    return .failure(.custom("notFollowedBy fail"))
                }
            }
        }
    }
    
    /// 尝试将self应用多次，每次将上一次和这一次的结果传入到next闭包，并将结果作为下一次的输入
    func reduce<U>(_ initVal: U, _ next: @escaping (U, T) -> U) -> Parser<U> {
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
            var remainder = tokens
            var last = initVal
            while case .success(let (current, rest)) = self.parse(remainder) {
                last = next(last, current)
                remainder = rest
            }
            return .success((last, remainder))
        }
    }
}
