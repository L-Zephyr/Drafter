//
//  SwiftMethodParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 method_definition  = ('class' | 'static')? 'func' NAME ‘(' param_list ')' return_type method_body
 param_list         = (param (',' param)*)?
 param              = ('_' | NAME)? NAME ':' param_type
 param_type         = ANY
 return_type        = (-> ANY)?
 method_body        = '{' BODY '}'
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
            try match(.function)
            let method = try methodContent()
            
            method.isStatic = true
            return method
            
        } else if token().type == .function {
            try match(.function)
            return try methodContent()
            
        } else if isInitMethod() {
            return try methodContent()
            
        } else {
            throw ParserError.notMatch("Not match func")
        }
    }
    
    func methodContent() throws -> MethodNode {
        let method = MethodNode()
        method.isSwift = true
        
        method.methodName = try match(.name).text // 方法名
        
        // 参数列表
        try match(.leftParen)
        method.params = try paramList()
        try match(.rightParen)
        
        // 返回值
        method.returnType = try returnType()
        
        // 函数体
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
        var parameter = Param(outterName: "", type: "", innerName: "")
        
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
        if token().text == "throws" || token().text == "rethrows" {
            consume()
        }
        
        var ret = [String]()
        if token().type == .rightArrow {
            try match(.rightArrow)
            // 判断返回值匹配结束
            
            // FIXME: - 这一块代码有点胶水，后续需优化
            var inside = 0
            while token().type != .endOfFile {
                if token().type == .rightArrow || token().type == .dot {
                    ret.append(token().text)
                    consume()
                }
                
                if token().type == .leftAngle || token().type == .leftParen {
                    inside += 1
                } else if token().type == .rightAngle || token().type == .rightParen {
                    inside -= 1
                }

                ret.append(token().text)
                consume()
                
                let end = token().type != .rightArrow && token().type != .dot && token().type != .leftAngle && token().type != .leftParen
                if inside == 0 && end {
                    break
                }
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

fileprivate extension SwiftMethodParser {
    
    func isInitMethod() -> Bool {
        if token().text == "init" && token(at: 1).type == .leftParen {
            return true
        }
        return false
    }
}
