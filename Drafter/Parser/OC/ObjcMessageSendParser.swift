//
//  ObjcMessageSendParser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/27.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 OC方法调用:
 statement
     = message_send ';'
 message_send
     = '[' receiver param_list ']'
 receiver
     = message_send | NAME
 param_list
     = NAME | (NAME ':' param)+
 */

/// 解析一个函数体中所有的OC方法调用，包括在block中的调用
class ObjcMessageSendParser: BacktrackParser {
    
    func parse() -> [MethodInvokeNode] {
        while token().type != .endOfFile {
            do {
                try statement()
            } catch {
//                print(error)
                consume()
            }
        }
        
        return nodes
    }
    
    fileprivate var nodes: [MethodInvokeNode] = []
    fileprivate var currentNode: MethodInvokeNode? = nil
}

// MARK: - 规则解析

fileprivate extension ObjcMessageSendParser {
    
    // TODO: - 处理@""中的情况
    func statement() throws {
        if isMessageSend() {
            let node = try messageSend()
            try match(.semicolon)
            
            nodes.append(node)
        } else {
            throw ParserError.notMatch("Not match message send")
        }
    }
    
    @discardableResult
    func messageSend() throws -> MethodInvokeNode {
        let node = MethodInvokeNode()
        
        try match(.leftSquare)
        
        node.invoker = try receiver()
        node.params = try paramList()
        
        try match(.rightSquare)
        
        return node
    }
    
    @discardableResult
    func receiver() throws -> MethodInvoker {
        if isMessageSend() { // receiver可能是另外一个方法调用的返回
            let node = try messageSend()
            return .method(node)
        } else {
            // 考虑xx.xx的情况
            var name = ""
            
            let property = try match(.name).text
            name.append(contentsOf: property)
            
            while token().type == .dot {
                try match(.dot)
                let property = try match(.name).text
                name.append(contentsOf: ".\(property)")
            }
            
            return .name(name)
        }
    }
    
    @discardableResult
    func paramList() throws -> [String] {
        var params: [String] = []
        
        if token().type == .name {
            if token(at: 1).type == .colon { // 有参数
                while token().type != .endOfFile && token().type != .rightSquare {
                    let name = try match(.name).text
                    
                    try match(.colon)
                    params.append("\(name):")
                    
                    try param()
                }
            } else { // 无参数
                let name = try match(.name).text
                params.append(name)
            }
        }
        
        return params
    }
    
    func param() throws {
        var inside = 0
        while token().type != .endOfFile {
            // 参数体解析结束
            let methodEnd = (token().type == .name && token(at: 1).type == .colon) || token().type == .rightSquare
            if inside == 0 && methodEnd {
                return
            }
            
            // 参数中的方法调用也添加到解析结果中
            if isMessageSend() {
                let msg = try messageSend()
                if !isSpeculating {
                    nodes.append(msg)
                }
                continue
            }
            
            // 处理嵌套的情况
            if token().type == .leftSquare || token().type == .leftBrace {
                inside += 1
            } else if token().type == .rightSquare || token().type == .rightBrace {
                inside -= 1
            }

            consume()
        }
    }
}

// MARK: - 推演

fileprivate extension ObjcMessageSendParser {
    
    func isMessageSend() -> Bool {
        var success = true
        mark()
        
        do {
            try messageSend()
        } catch {
            success = false
        }
        
        release()
        return success
    }
}
