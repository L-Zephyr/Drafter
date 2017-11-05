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
        case .failure(_):
            return nil
        }
    }
    
    /// 将执行结果转换成optional的版本
    var optional: Parser<T?> {
        return self.map { (result) -> T? in
            return result
        }
    }
}

//extension Parser where T == Token {
//    /// 将解析成功的token转换成字符串
//    var stringify: Parser<String> {
//        return Parser<String> { (tokens) -> Result<(String, Tokens)> in
//            switch self.parse(tokens) {
//            case .success(let (result, rest)):
//                return .success((result.text, rest))
//            case .failure(let error):
//                return .failure(error)
//            }
//        }
//    }
//}

/// 尝试执行Parser，执行结果为可选值，如果成功则包含执行结果，失败也同样返回success，结果为nil，不消耗任何输入
func trying<T>(_ p: Parser<T>) -> Parser<T?> {
    return Parser<T?> { (tokens) -> Result<(T?, Tokens)> in
        switch p.parse(tokens) {
        case .success(let (result, rest)):
            return .success((.some(result), rest))
        case .failure(_):
            return .success((nil, tokens))
        }
    }
}

/// 创建一个不消耗任何输入，直接返回给定值的Parser
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

/// 创建解析单个token的parser
func token(_ t: TokenType) -> Parser<Token> {
    return Parser(parse: { (tokens) -> Result<(Token, Tokens)> in
        guard let first = tokens.first, first.type == t else {
            let msg = "Expected type: \(t), found: \(tokens.first?.description ?? "empty")"
            return .failure(.missMatch(msg))
        }
        return .success((first, Array(tokens.dropFirst())))
    })
}
