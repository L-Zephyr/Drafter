//
//  SwiftInvokeParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/5.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 method_invoke = NAME '(' param_list? ')' callee?
 callee = '.' (method_invoke | NAME)
 param_list = param (param ',')*
 param = ...
 */
/// 解析swift方法的调用
class SwiftInvokeParser: BacktrackParser {
    
    func parse() -> [MethodInvokeNode] {
        while token().type != .endOfFile {
            do {
                let invoke = try methodInvoke()
                invokes.append(invoke)
            } catch {
                consume()
            }
        }
        
        return invokes
    }
    
    // MARK: - Private
    
    fileprivate var invokes: [MethodInvokeNode] = []
    // 保留的关键字
    fileprivate let reservedWords = ["if", "else", "do", "catch", "while", "repeat"]
}

// MARK: - 规则解析

fileprivate extension SwiftInvokeParser {
    
    func methodInvoke() throws -> MethodInvokeNode {
        let invoke = MethodInvokeNode()
        
        let name = try match(.name).text
        if reservedWords.contains(name) {
            throw ParserError.notMatch("Not match method def")
        }
        invoke.methodName = name
        
        if token().type == .leftBrace { // 只有一个尾随闭包的参数
            invoke.params.append("")
            try closure()
        } else {
            try match(.leftParen)
            invoke.params = try paramList()
            try match(.rightParen)
            
            // 还有尾随闭包
            if token().type == .leftBrace {
                invoke.params.append("")
                try closure()
            }
        }
        
        // 连续调用
        if let trailingInvoke = try callee() {
            trailingInvoke.topInvoker.invoker = .method(invoke)
            return trailingInvoke
        } else {
            return invoke
        }
    }
    
    func paramList() throws -> [String] {
        guard token().type != .rightParen else {
            return []
        }
        
        var params: [String] = []
        params.append(try param())
        
        while token().type != .rightParen && token().type != .endOfFile {
            try match(.comma)
            params.append(try param())
        }
        
        return params
    }
    
    func param() throws -> String {
        var paramName = ""
        // xx:
        if token().type == .name && token(at: 1).type == .colon {
            paramName.append(contentsOf: try match(.name).text)
            paramName.append(contentsOf: try match(.colon).text)
        }
        
        // 跳过参数值
        var inside = 0
        while token().type != .endOfFile {
            let paramEnd = token().type == .comma || token().type == .rightParen
            if inside == 0 && paramEnd {
                break
            }
            
            // 匹配闭包表达式
            if token().type == .leftBrace {
                try closure()
                continue
            }
            
            if token().type == .leftSquare {
                inside += 1
            } else if token().type == .rightSquare {
                inside -= 1
            }
            
            consume()
        }
        
        return paramName
    }
    
    /// 闭包定义要单独处理
    func closure() throws {
        try match(.leftBrace)
        
        var inside = 1
        while token().type != .endOfFile {
            if inside == 0 {
                break
            }
            
            // 参数闭包中的方法调用也解析出来
            if isMethodInvoke() {
                let invoke = try methodInvoke()
                if !isSpeculating {
                    invokes.append(invoke)
                }
                continue
            }
            
            if token().type == .leftBrace {
                inside += 1
            } else if token().type == .rightBrace {
                inside -= 1
            }
            
            consume()
        }
    }
    
    func callee() throws -> MethodInvokeNode? {
        if token().type == .dot {
            try match(.dot)
            if isMethodInvoke() {
                return try methodInvoke()
            }
        }
        return nil
    }
}

// MARK: - 推演

fileprivate extension SwiftInvokeParser {
    
    func isMethodInvoke() -> Bool {
        var success = true
        mark()
        
        do {
            _ = try methodInvoke()
        } catch {
            success = false
        }
        
        release()
        return success
    }
}
