//
//  ObjcMethodGenParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/11/5.
//

import Foundation

class ObjcMethodGenParser {
    
    func parse(_ tokens: Tokens) -> [ClassNode] {
        return []
    }
}

// MARK: - Parser

extension ObjcMethodGenParser {
    /// 解析OC方法声明
    /**
     method_decl       = ('-' | '+') type method_selector ';'
     type              = '(' TYPE_NAME ')'
     method_selector   = NAME | method_param_list
     method_param_list = (NAME ':' type NAME)+
     */
//    var methodDeclParser: Parser<MethodNode> {
//
//    }
    
    /// 解析OC方法定义
    /**
     method_definition = ('-' | '+') type method_selector method_body
     method_body       = '{' BODY '}'
     */
//    var methodDefParser: Parser<MethodNode> {
//
//    }
}

// MARK: - Helper

extension ObjcMethodGenParser {
    
}
