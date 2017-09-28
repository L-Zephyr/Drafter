//
//  ObjcMethodDefParser.swift
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
class ObjcMethodDefParser: RecallParser {
    
    func parse() -> [ObjcMethodNode] {
        while token().type != .endOfFile {
            if token().type == .plus || token().type == .minus {
                do {
                    try methodStat()
                } catch {
                    print(error)
                    consume()
                }
            } else {
                consume()
            }
        }
        
        return nodes
    }
    
    fileprivate var nodes: [ObjcMethodNode] = []
    fileprivate var currentNode: ObjcMethodNode? = nil
}

// MARK: - 规则解析

extension ObjcMethodDefParser {
    
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
            
            try match(.name)
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
        while token().type == .name || token().type == .asterisk {
            if token().type == .name {
                try match(.name)
            } else {
                try match(.asterisk)
            }
            typeName.append(lastToken?.text ?? "")
        }
        
        try match(.rightParen)
        
        return typeName.joined(separator: " ")
    }
    
    func methodBody() throws {
        if token().type != .leftBrace {
            throw ParserError.notMatch("Expected: \(TokenType.leftBrace), found: \(token().type)")
        }
        // TODO: 使用另一个parser解析函数体中的方法调用
        let invokeParser = ObjcMessageSendParser(lexer: self.input)
        let calls = invokeParser.parse()
        currentNode?.invokes = calls
    }
}

// MARK: - 规则推演

extension ObjcMethodDefParser {
    
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
