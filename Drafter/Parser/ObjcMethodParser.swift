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
 method_decl
     = ('-' | '+') type method_selector ';'
 type
     = '(' TYPE_NAME ')'
 method_selector
     = NAME | method_param_list
 method_param_list
     = (NAME ':' type NAME)+
 
 OC方法定义:
 method_definition
     = ('-' | '+') type method_selector method_body
 method_body
     = '{' BODY '}'
 
 method_stat = method_decl | method_definition
 
 */

/// 解析OC的方法定义
class ObjcMethodParser: RecallParser {
    
    func parse() -> [ObjcMethodNode] {
        // 1. 解析所有方法定义
        while token().type != .endOfFile {
            if token().type == .plus || token().type == .minus {
                do {
                    try methodStat()
                } catch {
//                    print(error)
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
    
    fileprivate var nodes: [ObjcMethodNode] = []
    fileprivate var currentNode: ObjcMethodNode? = nil
}

// MARK: - 规则解析

extension ObjcMethodParser {
    
    func methodStat() throws {
        if isMethodDef() {
            currentNode = ObjcMethodNode()
            try methodDefinition()
            currentNode.map { nodes.append($0) }
            currentNode = nil
        } else if isMethodDecl() {
            currentNode = ObjcMethodNode()
            try methodDecl()
            currentNode.map { nodes.append($0) }
            currentNode = nil
        } else {
            throw ParserError.notMatch("Unexpected found: \(token().type)")
        }
    }
    
    func methodDefinition() throws {
        try staticMethod()
        
        let retType = try type()
        currentNode?.returnType = retType
        
        try methodSelector()
        try methodBody()
    }
    
    func methodDecl() throws {
        try staticMethod()
        
        let retType = try type()
        currentNode?.returnType = retType
        
        try methodSelector()
        try match(.semicolon)
    }
    
    /// 类方法或实例方法
    func staticMethod() throws {
        if token().type == .plus {
            try match(.plus)
            currentNode?.isStatic = true
        } else if token().type == .minus {
            try match(.minus)
            currentNode?.isStatic = false
        } else {
            throw ParserError.notMatch("Expected: + or -, found: \(token().type)")
        }
    }
    
    func methodSelector() throws {
        if token().type == .name {
            if token(at: 1).type == .colon { // 带参数
                let params = try methodParamList()
                currentNode?.params = params
            } else { // 无参数
                try match(.name)
                currentNode?.params.append(Param(type: "", outter: lastToken?.text ?? "", inner: ""))
            }
        } else {
            throw ParserError.notMatch("Expected .name, found: \(token().type)")
        }
    }
    
    func methodParamList() throws -> [Param] {
        var params = [Param]()
        repeat {
            var param = Param()
            
            try match(.name) // 参数名称
            param.outterName = lastToken?.text ?? ""
            
            try match(.colon)
            param.type = try type()
            
            try match(.name)
            param.innerName = lastToken?.text ?? ""
            
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
    
    func methodBody() throws {
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
        
        currentNode?.methodBody = tokens
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
