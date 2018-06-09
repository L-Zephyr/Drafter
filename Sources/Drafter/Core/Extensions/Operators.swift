//
//  Operators.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 在parser失败的时候返回自定义的错误说明
///
/// - Parameters:
///   - p:     需要执行的parser
///   - msg:   自定义的错误信息
/// - Returns: 返回一个新的Parser，出错时返回msg
func <?><Token, Stream>(_ p: Parser<Token, Stream>, _ msg: String) -> Parser<Token, Stream> {
    return Parser<Token, Stream>(parse: { (input) -> ParseResult<(Token, Stream)> in
        switch p.parse(input) {
        case .success(let (r, remain)):
            return .success((r, remain))
        case .failure(_):
            return .failure(.custom(msg))
        }
    })
}

public extension Parser {
    /// 执行0次或多次parse，直到出错为止，解析结束返回结果列表，该Parser不会返回错误
    var many: Parser<[Token], Stream> {
        return Parser<[Token], Stream> { (stream) -> ParseResult<([Token], Stream)> in
            var result = [Token]()
            var remain = stream
            while true {
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    result.append(r)
                    remain = rest
                case .failure(_):
                    return .success((result.compactMap { $0 }, remain))
                }
            }
        }
    }
    
    /// 尝试执行1次或多次parse，结果为空则返回错误
    var many1: Parser<[Token], Stream> {
        return Parser<[Token], Stream> { (stream) -> ParseResult<([Token], Stream)> in
            var result = [Token]()
            var remain = stream
            while true {
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    result.append(r)
                    remain = rest
                case .failure(let error):
                    if result.count == 0 {
                        return .failure(error)
                    } else {
                        return .success((result.compactMap { $0 }, remain))
                    }
                }
            }
        }
    }
    
    /// `p.manyTill(end)`尝试多次应用p，直到end成功或解析错误为止，end不会消耗输入
    ///
    /// - Parameter end: 成功则表示结束
    /// - Returns:       成功解析的结果数组或错误
    func manyTill(_ end: Parser<Token, Stream>) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream> { (input) -> ParseResult<([Token], Stream)> in
            var remain = input
            var results = [Token]()
            while true {
                if case .success(_) = end.parse(remain) {
                    return .success((results.compactMap { $0 }, remain))
                }
                
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    results.append(r)
                    remain = rest
                case .failure(let error):
                    return .failure(error)
                }
            }
        }
    }
    
    /// `p.repeat(n)`尝试将解析器p至少应用n次，解析失败或成功次数少于n都会返回错误
    ///
    /// - Parameter num: 至少成功解析的次数
    /// - Returns:       成功解析的结果列表
    func `repeat`(_ num: Int) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream>(parse: { (input) -> ParseResult<([Token], Stream)> in
            var result = [Token]()
            var remainder = input
            var error: ParseError? = nil
            
            while true {
                switch self.parse(remainder) {
                case let .success((r, rest)):
                    result.append(r)
                    remainder = rest
                case let .failure(err):
                    error = err
                }
                if error != nil {
                    break
                }
            }
            
            if result.count >= num {
                return .success((result.compactMap { $0 }, remainder))
            } else if let err = error {
                return .failure(err)
            } else {
                return .failure(.unkown)
            }
        })
    }
    
    /// `p.count(n)`尝试将解析器p连续应用n次，返回结果集合
    ///
    /// - Parameter num: 解析次数, 为0则返回[]
    /// - Returns:       解析结果列表或错误
    func count(_ num: Int) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream>(parse: { (input) -> ParseResult<([Token], Stream)> in
            var results = [Token]()
            var remain = input
            for _ in 0..<num {
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    results.append(r)
                    remain = rest
                case .failure(let error):
                    return .failure(error)
                }
            }
            return .success((results.compactMap { $0 }, remain))
        })
    }
    
    /// 匹配0个或多个由separator分隔的self，在解析完最后一个项目之后不能跟着分隔符
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: parser的结果包含所有成功解析Token的数组，在解析完最后一个Token后如果还跟着分隔符的话会返回错误
    func sepBy<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream>(parse: { (stream) -> ParseResult<([Token], Stream)> in
            guard case let .success((first, remain)) = self.parse(stream) else {
                return .success(([], stream))
            }

            let remainParser = (separator *> self).many.notFollowedBy(separator)

            switch remainParser.parse(remain) {
            case let .success((tokens, r)):
                let results = [first] + tokens
                return .success((results.compactMap { $0 }, r))
            case .failure(let error):
                return .failure(error)
            }
        })
    }
    
    /// 至少匹配1个或多个由separator分隔的self，在解析完最后一个项目之后不能跟着分隔符
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: parser的结果包含所有成功解析Token的数组，数组中至少包含一个结果；在解析完最后一个Token后如果还跟着分隔符的话会返回错误，如果结果为空也会返回错误
    func sepBy1<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return self.flatMap({ (first) -> Parser<[Token], Stream> in
            return (separator *> self)
                .many
                .notFollowedBy(separator)
                .flatMap({ (tokens) -> Parser<[Token], Stream> in
                    return .result([first] + tokens)
                })
        })
    }
    
    /// 匹配0个或多个由separator分隔的self，在解析完最后一个项目之后跟着分隔符，最后一个分隔符会被消耗掉但不会出现在结果中
    ///
    /// - Parameter separator: 分隔符规则
    /// - Returns: 结果数组，不会返回错误
    func endBy<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return (self <* separator).many
    }
    
    /// 匹配0个或多个由separator分隔的self，在解析完最后一个项目之后跟着分隔符，最后一个分隔符会被消耗掉但不会出现在结果中，返回的数组至少有一个结果
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: 解析成功的结果数组或错误信息
    func endBy1<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return (self <* separator).many1
    }
    
    /// 按照顺序依次解析open、self、close，最后返回self的结果，open和close会消耗输入但不会出现在结果中
    ///
    /// - Parameters:
    ///   - open:  在self左侧的操作符
    ///   - close: 在self右侧的操作符
    /// - Returns: 解析成功返回self的解析结果，失败返回错误
    func between<L, R>(_ open: Parser<L, Stream>, _ close: Parser<R, Stream>) -> Parser<Token, Stream> {
        return open *> self <* close;
    }
    
    /// 尝试解析，如果失败的话返回结果nil且不消耗输入，不会返回错误
    var `try`: Parser<Token?, Stream> {
        return Parser<Token?, Stream>(parse: { (input) -> ParseResult<(Token?, Stream)> in
            switch self.parse(input) {
            case .success(let (r, remain)):
                return .success((r, remain))
            case .failure(_):
                return .success((nil, input))
            }
        })
    }
    
    /// 尝试解析应用当前的Parser，执行成功不会消耗输入
    var lookahead: Parser<Token, Stream> {
        return Parser<Token, Stream>(parse: { (input) -> ParseResult<(Token, Stream)> in
            switch self.parse(input) {
            case .success(let (r, _)):
                return .success((r, input))
            case .failure(let error):
                return .failure(error)
            }
        })
    }
    
    /// `self.notFollowedBy(p)`仅当p失败的时候返回成功，不会消耗输入，成功时返回self的值
    ///
    /// - Parameter p: 任意结果类型的Parser
    /// - Returns: 新的Parser，成功时返回self的结果
    func notFollowedBy<U>(_ p: Parser<U, Stream>) -> Parser<Token, Stream> {
        let not = Parser<U?, Stream>(parse: { (input) -> ParseResult<(U?, Stream)> in
            switch p.parse(input) {
            case .success(let (r, _)):
                return .failure(.notMatch("Unexpected found: \(r)"))
            case .failure(_):
                return .success((nil, input))
            }
        })
        
        return self <* not
    }
}
