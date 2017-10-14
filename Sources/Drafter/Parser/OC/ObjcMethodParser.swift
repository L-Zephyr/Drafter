//
//  ObjcMethodParser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/27.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Cocoa

/*
 OC方法声明:
 method_decl       = ('-' | '+') type method_selector ';'
 type              = '(' TYPE_NAME ')'
 method_selector   = NAME | method_param_list
 method_param_list = (NAME ':' type NAME)+
 
 OC方法定义:
 method_definition = ('-' | '+') type method_selector method_body
 method_body       = '{' BODY '}'
 
 method_stat = method_decl | method_definition
 
 */

/// 解析OC的方法定义
class ObjcMethodParser: BacktrackParser {
    
    func parse() -> [MethodNode] {
        // 1. 解析所有方法定义
        while token().type != .endOfFile {
            if token().type == .plus || token().type == .minus {
                do {
                    try methodStat()
                } catch {
                    consume()
                }
            } else {
                consume()
            }
        }
        
        // 2. 解析函数体中的方法调用
        for node in nodes {
            if node.methodBody.count != 0 {
                let lexer = TokenLexer(tokens: node.methodBody)
                let parser = ObjcMessageSendParser(lexer: lexer)
                node.invokes = parser.parse()
            }
        }
        
        return nodes
    }
    
    fileprivate var nodes: [MethodNode] = []
}

// MARK: - 规则解析

extension ObjcMethodParser {
    
    func methodStat() throws {
        if isMethodDef() {
            let method = try methodDefinition()
            nodes.append(method)
            
        } else if isMethodDecl() {
            let method = try methodDecl()
            nodes.append(method)
            
        } else {
            throw ParserError.notMatch("Unexpected found: \(token().type)")
        }
    }
    
    @discardableResult
    func methodDefinition() throws -> MethodNode {
        let method = MethodNode()
        
        method.isStatic = try staticMethod()
        method.returnType = try type()
        method.params = try methodSelector()
        method.methodBody = try methodBody()
        
        return method
    }
    
    @discardableResult
    func methodDecl() throws -> MethodNode {
        let method = MethodNode()
        
        method.isStatic = try staticMethod()
        method.returnType = try type()
        method.params = try methodSelector()
        
        try match(.semicolon)
        
        return method
    }
    
    /// 类方法或实例方法
    func staticMethod() throws -> Bool {
        if token().type == .plus {
            try match(.plus)
            return true
        } else if token().type == .minus {
            try match(.minus)
            return false
        } else {
            throw ParserError.notMatch("Expected: + or -, found: \(token().type)")
        }
    }
    
    func methodSelector() throws -> [Param] {
        if token().type == .name {
            if token(at: 1).type == .colon { // 带参数
                return try methodParamList()
            } else { // 无参数
                let outterName = try match(.name).text
                return [Param(type: "", outter: outterName, inner: "")]
            }
        } else {
            throw ParserError.notMatch("Expected .name, found: \(token().type)")
        }
    }
    
    func methodParamList() throws -> [Param] {
        var params = [Param]()
        repeat {
            var param = Param()
            
            param.outterName = try match(.name).text // 参数名称
            
            try match(.colon)
            param.type = try type()
            
            param.innerName = try match(.name).text // 内部形参名称
            
            // 可变参数，暂不匹配
            if token().type == .comma {
                consume(step: 4)
            }
            
            params.append(param)
        } while token().type == .name
        
        return params
    }
    
    func type() throws -> String {
        try match(.leftParen)
        
        // 类型直接作为字符常量匹配
        var typeName = [String]()
        var parenCount = 1

        while token().type != .endOfFile {
            if token().type == .leftParen {
                parenCount += 1
            } else if token().type == .rightParen {
                parenCount -= 1
                if parenCount == 0 {
                    break
                }
            }
            
            typeName.append(token().text)
            consume()
        }
        
        try match(.rightParen)
        
        return typeName.joined(separator: " ")
    }
    
    func methodBody() throws -> [Token] {
        try match(.leftBrace)
        
        // 匹配整个函数体
        var tokens = [Token]()
        var leftBraceCount = 1
        
        while token().type != .endOfFile {
            if token().type == .leftBrace {
                leftBraceCount += 1
            } else if token().type == .rightBrace {
                leftBraceCount -= 1
                if leftBraceCount == 0 {
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

// MARK: - 规则推演

extension ObjcMethodParser {
    
    func isMethodDef() -> Bool {
        var success = false
        mark()
        
        do {
            try methodDefinition()
            success = true
        } catch { }
        
        release()
        return success
    }
    
    func isMethodDecl() -> Bool {
        var success = false
        mark()
        
        do {
            try methodDecl()
            success = true
        } catch { }
        
        release()
        return success
    }
}
