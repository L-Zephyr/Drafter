//
//  InterfaceParser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 OC调用文法
 invoke: '[' NAME methodBody ']' ';'
 methodBody: (methodName ':' 'NAME ')* | methodName
 methodName: NAME
 
 C语言调用文法
 invoke: funcName '(' paramList ')'
 paramList: NAME (',' NAME)* | ''
 funcName: NAME
 */

/// 函数调用解析器
class InvokeParser {
    
    init(lexer: Lexer) {
        self.input = lexer
    }
    
    // MARK: - Private
    
    fileprivate var input: Lexer
}
