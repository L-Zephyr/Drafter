//
//  ClassParser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 保存类型信息的节点
class ClassNode: Node {
    
}

/*
 classDecl: '@interface' className (':' className)* ('<' protocols '>')*
 className: NAME
 protocols: NAME (',' NAME)*
 */

/// 类型定义的parser
class ClassParser: Parser {
    
    init(lexer: Lexer) {
        self.input = lexer
    }
    
    func parse() throws {
        
    }
    
    // MARK: - Private
    
    fileprivate var input: Lexer
}

// MARK: - 文法规则解析

extension ClassParser {
    func classDecl() throws {
        
    }
    
    func protocols() throws {
        
    }
}
