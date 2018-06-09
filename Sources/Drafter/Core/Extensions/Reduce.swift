//
//  Reduce.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/5/27.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

extension Parser {
    /// 解析self.many，并将结果通过combinator结合起来，用法类似Sequence的reduce
    ///
    /// - Parameters:
    ///   - first: 初始值
    ///   - combinator: 接收初始值和self的解析结果作为输入，返回值作为下一次的输入
    /// - Returns: 累积的结果，该Parser不会失败
    func reduce<Result>(_ first: Result, _ combinator: @escaping (Result, Token) -> Result) -> Parser<Result, Stream> {
        return self.many.map { (nextList) -> Result in
            nextList.reduce(first, { (first, two) -> Result in
                return combinator(first, two)
            })
        }
    }
    
    /// `p.reduce(val, op)`取 val 作为累加值的初始，然后再尝试解析一个 op 和 p ，将累加值和p的结果作为参数传入到op返回的闭包中，将结果作为下一次的参数，循环op和p的解析直到失败为止
    ///
    /// - Parameters:
    ///   - initValue: 初始值，使用该值作为第一个参数传入闭包，并将结果累积
    ///   - combinator: 参与解析并返回一个闭包，该闭包的计算结果将作为累积的值参与下一次运算
    /// - Returns: 累积的结果，该Parser不会失败
    func reduce<Result>(_ initValue: Result, _ combinator: Parser<(Result, Token) -> Result, Stream>) -> Parser<Result, Stream> {
        return Parser<Result, Stream>(parse: { (input) -> ParseResult<(Result, Stream)> in
            var result = initValue
            var remain = input
            while case .success(let (op, r1)) = combinator.parse(remain), case .success(let (num, r2)) = self.parse(r1) {
                result = op(result, num)
                remain = r2
            }
            return .success((result, remain))
        })
    }
    
    /// `p.chainL(op)`首先取 p 的解析结果作为累加值（初始），然后再尝试解析一个 op 和 p ，将累加值和p的结果作为参数传入到op返回的闭包中，将结果作为下一次的参数，循环op和p的解析直到失败为止
    ///
    /// - Parameter op: 解析结果为一个闭包，用于计算后续的累积值
    /// - Returns: 累积的结果，当self第一次解析失败的时候返回错误
    func chainL(_ op: Parser<(Token, Token) -> Token, Stream>) -> Parser<Token, Stream> {
        return self.flatMap { self.reduce($0, op) }
    }
    
    /// 解析过程与chainL类似，但是结果累积的过程是相反的
    ///
    /// - Parameter combinator: 解析结果为一个闭包，用于计算后续的累积值
    /// - Returns: 计算从右向左累积的结果，当self第一次解析失败的时候返回错误
    func chainR(_ combinator: Parser<(Token, Token) -> Token, Stream>) -> Parser<Token, Stream> {
        return self.flatMap({ (initValue) -> Parser<Token, Stream> in
            return Parser<Token, Stream>(parse: { (input) -> ParseResult<(Token, Stream)> in
                var remain = input
                
                var ops = [(Token, Token) -> Token]()
                var nums: [Token] = [initValue]
                while case .success(let (op, r1)) = combinator.parse(remain), case .success(let (num, r2)) = self.parse(r1) {
                    ops.append(op)
                    nums.append(num)
                    remain = r2
                }
                
                var result = nums.last!
                // 从右向左累积
                for index in (0..<ops.count).reversed() {
                    result = ops[index](nums[index], result)
                }
                
                return .success((result, remain))
            })
        })
    }
}
