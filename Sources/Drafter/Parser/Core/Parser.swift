//
//  ParserType.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation

// MARK: - Parser

typealias Tokens = [Token]

struct Parser<T> {
    var parse: (Tokens) -> Result<(T, Tokens)>
}

// MARK: - Parser Extensions

extension Parser {
    /// 执行parser，只返回结果
    func run(_ tokens: Tokens) -> T? {
        switch self.parse(tokens) {
        case .success(let (result, _)):
            return result
        case .failure(let error):
            #if DEBUG
            print("\(error)")
            #endif
            return nil
        }
    }
    
    /// 将执行结果转换成optional的版本
    var optional: Parser<T?> {
        return self.map { (result) -> T? in
            return result
        }
    }
    
    /// 连续执行该Parser直到输入耗尽为止，将所有的结果放在数组中返回，不会返回错误
    var continuous: Parser<[T]> {
        return Parser<[T]> { (tokens) -> Result<([T], Tokens)> in
            var result = [T]()
            var remainder = tokens
            while remainder.count != 0 {
                switch self.parse(remainder) {
                case .success(let (t, rest)):
                    result.append(t)
                    remainder = rest
                case .failure(let error):
                    #if DEBUG
                        print("fail: \(error), continuous to next")
                    #endif
                    remainder = Array(remainder.dropFirst())
                    continue
                }
            }
            
            return .success((result, remainder))
        }
    }
}

/// 尝试执行Parser，执行结果为可选值，如果成功则包含执行结果，失败也同样返回success，结果为nil，不消耗任何输入
func trying<T>(_ p: Parser<T>) -> Parser<T?> {
    return Parser<T?> { (tokens) -> Result<(T?, Tokens)> in
        switch p.parse(tokens) {
        case .success(let (result, rest)):
            return .success((result, rest))
        case .failure(_):
            return .success((nil, tokens))
        }
    }
}

/// 直接返回给定结果，不会消耗输入
func pure<T>(_ t: T) -> Parser<T> {
    return Parser(parse: { (tokens) -> Result<(T, Tokens)> in
        return .success((t, tokens))
    })
}

/// 创建一个始终返回错误的parser
func fail<T>(_ error: ParserError = .unknown) -> Parser<T> {
    return Parser(parse: { (tokens) -> Result<(T, Tokens)> in
        return .failure(error)
    })
}

/// 创建解析单个token并消耗输入, 失败时不消耗输入
func token(_ t: TokenType) -> Parser<Token> {
    return Parser(parse: { (tokens) -> Result<(Token, Tokens)> in
        guard let first = tokens.first, first.type == t else {
            let msg = "Expected type: \(t), found: \(tokens.first?.description ?? "empty")"
            return .failure(.missMatch(msg))
        }
//        print("consume token: \(first)")
        return .success((first, Array(tokens.dropFirst())))
    })
}

// MARK: - Sequence Match

/// 匹配任意Token类型的Parser直到条件为false，该Parser不会返回错误
func anyToken(until: @escaping (Token) -> Bool) -> Parser<[Token]> {
    return Parser<[Token]> { (tokens) -> Result<([Token], Tokens)> in
        var result = [Token]()
        var remainder = tokens
        for token in remainder {
            if until(token) {
                break
            }
            result.append(token)
            _ = remainder.removeFirst()
        }
        return .success((result, remainder))
    }
}

/// 获取任意Token知道p成功为止, p不会消耗输入
func anyToken(until p: Parser<Token>) -> Parser<[Token]> {
    return Parser<[Token]> { (tokens) -> Result<([Token], Tokens)> in
        var remainder = tokens
        var result = [Token]()
        while true {
            switch p.parse(remainder) {
            case .success(_):
                return .success((result, remainder))
            case .failure(_):
                result.append(remainder.removeFirst())
            }
        }
    }
}

/// 匹配在l和r之间的任意Token，l和r也会被消耗掉
func anyToken(between l: TokenType, and r: TokenType) -> Parser<[Token]> {
    // 这里使用捕获的变量inside会有问题，因为这个Parser会被反复调用，但是inside只会初始化一次
    // TODO: anyToken需要重新设计
    var inside = 1
    let any = anyToken(until: { token in
        if token.type == l {
            inside += 1
        } else if token.type == r {
            inside -= 1
        }
        
        if inside == 0 {
            inside = 1
            return true
        } else {
            return false
        }
    })
    
    return token(l) *> any <* token(r)
}

//func anyToken(between l: Parser<Token>, and r: Parser<Token>) -> Parser<[Token]> {
//    return Parser<[Token]> { (tokens) -> Result<([Token], Tokens)> in
//
//    }
//}

