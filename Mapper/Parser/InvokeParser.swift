//
//  InterfaceParser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 OC方法声明
 methodStat: ('-' | '+') '(' type ')' NAME params ';'
 params: ':' '(' type ')' NAME (paramList)* | ''
 paramList: (NAME ':' '(' type ')' NAME)*
 type: NAME
 
 OC方法调用文法
 message_expression
     = '[' receiver message_selector ']'
 receiver
     = 'self' | 'super' | NAME
 message_selector
     = NAME | (NAME ':' NAME)*
  */

/// 函数调用解析器
class InvokeParser: RecallParser {
    
    func parse() -> [InvokeNode] {
        return []
    }
}

// MARK: - 文法规则解析

extension InvokeParser {
    
    // 方法声明
    func methodStat() throws {
        
    }
}
