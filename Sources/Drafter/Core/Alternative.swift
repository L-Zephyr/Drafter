//
//  Alternative.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

public func <|> <T, S>(lhs: Parser<T, S>, rhs: Parser<T, S>) -> Parser<T, S> {
    return lhs.or(rhs)
}

public extension Parser {
    
    /// 在`q.or(p)`中，先尝试应用q，成功则直接返回结果，失败则使用最初的输入继续尝试p，返回p的结果
    ///
    /// - Parameter p: Parser，失败时的第二选择
    /// - Returns:     任一parser的解析结果或错误信息
    func or(_ p: Parser<Token, Stream>) -> Parser<Token, Stream> {
        return Parser<Token, Stream>(parse: { (tokens) -> ParseResult<(Token, Stream)> in
            let r = self.parse(tokens)
            switch r {
            case .success(_):
                return r
            case .failure(_):
                return p.parse(tokens) // 左侧失败时不消耗输入
            }
        })
    }
    
    /// 静态方法，提供一个parser数组，依次尝试每一个parser直到有一个成功为止，如果全部失败返回最后一个parser的错误信息
    ///
    /// - Parameter ps: parser的数组，数组为空会返回一个Unknown错误
    /// - Returns:      任一成功的值或最后一个parser的错误信息
    static func choice(_ ps: [Parser<Token, Stream>]) -> Parser<Token, Stream> {
        return Parser<Token, Stream>(parse: { (input) -> ParseResult<(Token, Stream)> in
            if ps.count == 0 {
                return .failure(ParseError.unkown) // TODO: 错误类型？
            }
            
            var error: ParseError = ParseError.unkown
            for parser in ps {
                switch parser.parse(input) {
                case .success(let (r, remain)):
                    return .success((r, remain))
                case .failure(let err):
                    error = err
                    continue
                }
            }
            return .failure(error)
        })
    }
    
    /// choice的变长参数版本
    static func choice(_ ps: Parser<Token, Stream>...) -> Parser<Token, Stream>  {
        return self.choice(ps)
    }
}
