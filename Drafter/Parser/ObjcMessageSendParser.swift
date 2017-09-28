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
 message_send
     = '[' receiver param_list ']'
 receiver
     = NAME
 param_list
     = NAME | (NAME ':' ANY)+
 */

/// 解析一个函数体中所有的OC方法调用
class ObjcMessageSendParser: RecallParser {
    
    func parse() -> [ObjcMessageNode] {
        do {
            try match(.leftBrace)
            
            try match(.rightBrace)
        } catch {
            print(error)
        }
        
        return nodes
    }
    
    fileprivate var nodes: [ObjcMessageNode] = []
    fileprivate var currentNode: ObjcMessageNode? = nil
}

// MARK: - 规则解析

fileprivate extension ObjcMessageSendParser {
    
    func messageSend() throws {
        try match(.leftBrace)
        
        try match(.rightBrace)
    }
    
    func receiver() throws {
        try match(.name)
        currentNode?.receiver = lastToken?.text ?? ""
    }
    
    func paramList() throws {
        if token().type == .name {
            if token(at: 1).type == .colon { // 有参数
                
            } else { // 无参数
                
            }
        }
    }
}
