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
     = NAME | (NAME ':' ANY)+
 */

/// 解析一个函数体中所有的OC方法调用, 忽略Block中的调用?
class ObjcMessageSendParser: RecallParser {
    
    func parse() -> [ObjcMessageNode] {
        while token().type != .endOfFile {
            if token().type == .leftSquare {
                do {
                    try statement()
                } catch {
                    consume()
                }
            } else {
                consume()
            }
        }
        
        return nodes
    }
    
    fileprivate var nodes: [ObjcMessageNode] = []
    fileprivate var currentNode: ObjcMessageNode? = nil
}

// MARK: - 规则解析

fileprivate extension ObjcMessageSendParser {
    
    func statement() throws {
        if isMessageSend() {
            try messageSend()
            try match(.semicolon)
        } else {
            throw ParserError.notMatch("Not match message send")
        }
    }
    
    func messageSend() throws {
        try match(.leftSquare)
        try receiver()
        try paramList()
        try match(.rightSquare)
    }
    
    func receiver() throws {
        if isMessageSend() {
            try messageSend()
        } else {
            try match(.name)
        }
    }
    
    func paramList() throws {
        if token().type == .name {
            if token(at: 1).type == .colon { // 有参数
                
            } else { // 无参数
                try match(.name) // TODO: 方法名
            }
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
    
    func isBlock() -> Bool {
        return false
    }
}
