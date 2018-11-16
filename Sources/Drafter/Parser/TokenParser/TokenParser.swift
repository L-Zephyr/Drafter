//
//  ConcreteParserType.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/10/31.
//

import Foundation
import SwiftyParse

// MARK: - TokenParser

typealias Tokens = [Token]
typealias TokenParser<T> = Parser<T, Tokens>

// MARK: - TokenParser Extensions

extension Parser where Stream == Tokens {
    /// 执行parser，只返回结果
    func run(_ tokens: Tokens) -> Result? {
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

    /// 连续执行该Parser直到输入耗尽为止，将所有的结果放在数组中返回，不会返回错误
    var continuous: TokenParser<[Result]> {
        return TokenParser<[Result]> { (tokens) -> ParseResult<([Result], Tokens)> in
            var result = [Result]()
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

/// 创建一个始终返回指定值的的算子，不消耗输入
func pure<T>(_ t: T) -> TokenParser<T> {
    return TokenParser<T>.result(t)
}

// MARK: - 这些都要去掉

/// 创建一个始终返回错误的parser
func error<T>(_ err: ParseError = .unkown) -> TokenParser<T> {
    return TokenParser<T>.error(err)
}

/// 解析单个token并消耗输入, 失败时不消耗输入
func token(_ t: TokenType) -> TokenParser<Token> {
    return Parser(parse: { (tokens) -> ParseResult<(Token, Tokens)> in
        guard let first = tokens.first, first.type == t else {
            let msg = "Expected type: \(t), found: \(tokens.first?.description ?? "empty")"
            return .failure(.notMatch(msg))
        }
        #if DEBUG
        print("match token: \(first)")
        #endif
        return .success((first, Array(tokens.dropFirst())))
    })
}

// MARK: - Any Tokens

/// 匹配任意一个Token
var anyToken: TokenParser<Token> {
    return Parser { (tokens) -> ParseResult<(Token, Tokens)> in
        guard let first = tokens.first else {
            return .failure(.custom("tokens empty"))
        }
        return .success((first, Array(tokens.dropFirst())))
    }
}

/// 获取任意Token知道p成功为止, p不会消耗输入，该方法不会返回错误
func anyTokens(until p: TokenParser<Token>) -> TokenParser<[Token]> {
    return (p.not *> anyToken).many
}

/// 匹配在l和r之间的任意Token，l和r也会被消耗掉并出现在结果中，lr匹配失败时会返回错误
func anyTokens(encloseBy l: TokenParser<Token>, and r: TokenParser<Token>) -> TokenParser<[Token]> {
    let content = l.lookahead *> lazy(anyTokens(encloseBy: l, and: r)) // 递归匹配
        <|> ({ [$0] } <^> (r.not *> anyToken)) // 匹配任意token直到碰到r
    
    return curry({ [$0] + Array($1.joined()) + [$2] })
        <^> l
        <*> content.many
        <*> r
}

/// 匹配在l和r之间的任意Token，l和r会被消耗掉，但不会出现在结果中，lr匹配失败时会返回错误
func anyTokens(inside l: TokenParser<Token>, and r: TokenParser<Token>) -> TokenParser<[Token]> {
    return anyTokens(encloseBy: l, and: r).map {
        Array($0.dropFirst().dropLast()) // 去掉首尾的元素
    }
}

/// 任意被包围在{}、[]、()或<>中的符号
var anyEnclosedTokens: TokenParser<[Token]> {
    return anyTokens(encloseBy: token(.leftBrace), and: token(.rightBrace)) // {..}
        <|> anyTokens(encloseBy: token(.leftSquare), and: token(.rightSquare)) // [..]
        <|> anyTokens(encloseBy: token(.leftParen), and: token(.rightParen)) // (..)
        <|> anyTokens(encloseBy: token(.leftAngle), and: token(.rightAngle)) // <..>
}

/// 匹配任意字符直到p失败为止，p只有在不被{}、[]、()或<>包围时进行判断
func anyOpenTokens(until p: TokenParser<Token>) -> TokenParser<[Token]> {
    return { $0.flatMap {$0} }
        <^> (p.not *> (anyEnclosedTokens <|> anyToken.map { [$0] })).many
}

// MARK: - lazy

///
func lazy<T>(_ parser: @autoclosure @escaping () -> TokenParser<T>) -> TokenParser<T> {
    return TokenParser<T> { parser().parse($0) }
}

