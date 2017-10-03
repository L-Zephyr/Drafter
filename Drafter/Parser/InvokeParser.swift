//
//  InterfaceParser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*

 OC方法调用:
 message_expression
     = '[' receiver message_selector ']'
 receiver
     = 'self' | 'super' | NAME
 message_selector
     = NAME | (NAME ':' NAME)*
*/

/// 函数调用解析器
class InvokeParser: BacktrackParser {
    
    func parse() -> [InvokeNode] {
        return []
    }
}


