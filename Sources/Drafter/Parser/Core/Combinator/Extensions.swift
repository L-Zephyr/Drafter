//
//  Extensions.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

extension Parser {
    
    // TODO: - many有可能丢失错误信息？
    
    /// 多次重复该parser直到失败为止，将结果保存在数组中返回
    var many: Parser<[T]> {
        return Parser<[T]> { (tokens) -> Result<([T], Tokens)> in
            var result = [T]()
            var remainder = tokens
            while case .success(let (r, rest)) = self.parse(remainder) {
                result.append(r)
                remainder = rest
            }
            return .success((result, remainder))
        }
    }
    
    /// 解析一串由指定标签分隔的值，返回包含所有成功解析的值
    func separateBy<U>(_ p: Parser<U>) -> Parser<[T]> {
        return curry({ $0 + [$1] }) <^> (self <* p).many <*> self
    }
    
    /// 解析包含在指定标签之间的值: p self p
    func between<A, B>(_ left: Parser<A>, _ right: Parser<B>) -> Parser<T> {
        return left *> self <* right
    }
}
