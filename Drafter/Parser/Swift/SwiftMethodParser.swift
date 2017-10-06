//
//  SwiftMethodParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 method_definition = ('class' | 'static')? 'func' NAME ‘(' param_list ')' return_type method_body
 param_list = (param (',' param)*)?
 param = ('_' | NAME)? NAME ':' param_type
 param_type = ANY
 return_type = (-> ANY)?
 method_body = '{' BODY '}'
 */
class SwiftMethodParser: BacktrackParser {
    
    func parse() -> [MethodNode] {
        // 1. 解析方法定义
        while token().type != .endOfFile {
            do {
                let method = try methodDefinition()
                methods.append(method)
            } catch {
                consume()
            }
        }
        
        // 2. 解析函数体中的方法调用
        for method in methods {
            if method.methodBody.count != 0 {
                let lexer = TokenLexer(tokens: method.methodBody)
                let parser = SwiftInvokeParser(lexer: lexer)
                method.invokes = parser.parse()
            }
        }
        
        return methods
    }
    
    // MARK: - Private
    
    fileprivate var methods: [MethodNode] = []
}

// MARK: - 规则解析

fileprivate extension SwiftMethodParser {
    
    func methodDefinition() throws -> MethodNode {
        
        if (token().type == .statical || token().type == .cls) && token(at: 1).type == .function {
            if token().type == .statical {
                try match(.statical)
            } else {
                try match(.cls)
            }
            let method = try methodDef()
            
            method.isStatic = true
            return method
            
        } else if token().type == .function {
            return try methodDef()
            
        } else {
            throw ParserError.notMatch("Not match func")
        }
    }
    
    func methodDef() throws -> MethodNode {
        let method = MethodNode()
        method.isSwift = true
        
        try match(.function)
        method.methodName = try match(.name).text
        
        try match(.leftParen)
        method.params = try paramList()
        try match(.rightParen)
        
        method.returnType = try returnType()
        
        method.methodBody = try methodBody()
        
        return method
    }
    
    func paramList() throws -> [Param] {
        var params = [Param]()
        
        while token().type != .endOfFile && token().type != .rightParen {
            if token().type == .comma {
                consume()
            }
            
            let p = try param()
            params.append(p)
        }
        
        return params
    }
    
    func param() throws -> Param {
        var parameter = Param()
        
        if token().type == .underline {
            try match(.underline)
            parameter.innerName = try match(.name).text
            
        } else if token().type == .name {
            parameter.outterName = try match(.name).text
            if token().type == .name {
                parameter.innerName = try match(.name).text
            } else {
                parameter.innerName = parameter.outterName
            }
        }
        
        try match(.colon)
        parameter.type = try paramType()
        
        return parameter
    }
    
    func paramType() throws -> String {
        var type = ""
        var inside = 0
        
        while token().type != .endOfFile {
            // 跳过@autoclosure和inout修饰符
            if token().type == .at && token(at: 1).text == "autoclosure" {
                consume()
                consume()
                continue
            }
            
            if token().text == "inout" {
                consume()
                continue
            }
            
            // 解析结束
            let end = token().type == .rightParen || token().type == .comma
            if inside == 0 && end {
                break
            }
            
            if token().type == .leftParen {
                inside += 1
            } else if token().type == .rightParen {
                inside -= 1
            }
            
            type.append(contentsOf: "\(token().text)")
            
            consume()
        }
        
        return type
    }
    
    func returnType() throws -> String {
        var ret = [String]()
        if token().type == .rightArrow {
            try match(.rightArrow)
            
            while token().type != .endOfFile && token().type != .leftBrace {
                ret.append(token().text)
                consume()
            }
        }
        
        return ret.joined(separator: " ")
    }
    
    func methodBody() throws -> [Token] {
        try match(.leftBrace)
        
        var tokens = [Token]()
        var inside = 1
        
        while token().type != .endOfFile {
            if token().type == .leftBrace {
                inside += 1
            } else if token().type == .rightBrace {
                inside -= 1
                if inside == 0 {
                    break
                }
            }
            
            tokens.append(token())
            consume()
        }
        
        try match(.rightBrace)
        
        return tokens
    }
    
}
