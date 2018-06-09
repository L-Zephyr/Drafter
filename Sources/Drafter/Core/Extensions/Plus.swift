//
//  Plus.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/4/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

/*
 `plus`操作符，从左向右依次解析两个相同类型的Parser，并将它们的结果保存在数组中返回
 */
precedencegroup ParserPlusLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

// MARK: - +

infix operator ++ : ParserPlusLeft

// Token + Token = [Token]
func ++ <Token, Stream>(_ lhs: Parser<Token, Stream>, _ rhs: Parser<Token, Stream>) -> Parser<[Token], Stream> {
    return lhs.plus(rhs)
}

// Token + [Token] = [Token]
func ++ <Token, Stream>(_ lhs: Parser<Token, Stream>, _ rhs: Parser<[Token], Stream>) -> Parser<[Token], Stream> {
    return lhs.plus(rhs)
}

// [Token] + Token = [Token]
func ++ <Token: Sequence, Stream>(_ lhs: Parser<Token, Stream>, _ rhs: Parser<Token.Element, Stream>) -> Parser<[Token.Element], Stream> {
    return lhs.plus(rhs)
}

// [Token] + [Token] = [Token]
func ++ <Token:Sequence, Stream>(_ lhs: Parser<Token, Stream>, _ rhs: Parser<Token, Stream>) -> Parser<[Token.Element], Stream> {
    return lhs.plus(rhs)
}

// MARK: - Plus

extension Parser {
    func plus(_ parser: Parser<Token, Stream>) -> Parser<[Token], Stream> {
        return self.flatMap({ (result1) -> Parser<[Token], Stream> in
            return parser.flatMap({ (result2) -> Parser<[Token], Stream> in
                return .result([result1, result2])
            })
        })
    }
    
    func plus(_ parser: Parser<[Token], Stream>) -> Parser<[Token], Stream> {
        return self.flatMap({ (result1) -> Parser<[Token], Stream> in
            return parser.flatMap({ (result2) -> Parser<[Token], Stream> in
                return .result([result1] + result2)
            })
        })
    }
}

extension Parser where Token: Sequence {
    func plus(_ parser: Parser<Token.Element, Stream>) -> Parser<[Token.Element], Stream> {
        return self.flatMap({ (tokens) -> Parser<[Token.Element], Stream> in
            return parser.flatMap({ (token) -> Parser<[Token.Element], Stream> in
                return .result(Array(tokens) + [token])
            })
        })
    }
    
    func plus(_ parser: Parser<Token, Stream>) -> Parser<[Token.Element], Stream> {
        return self.flatMap({ (tokens1) -> Parser<[Token.Element], Stream> in
            return parser.flatMap({ (tokens2) -> Parser<[Token.Element], Stream> in
                return .result(Array(tokens1) + Array(tokens2))
            })
        })
    }
}
