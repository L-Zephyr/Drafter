//
//  ObjcMessageGenParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/8.
//

import Foundation

class ObjcMessageGenParser: ParserType {
    func parse(_ tokens: Tokens) -> [MethodInvokeNode] {
        return []
    }
}

// MARK: - Parser

/*
 statement    = message_send ';'
 message_send = '[' receiver param_list ']'
 receiver     = message_send | NAME
 param_list   = NAME | (NAME ':' param)+
 param        = ...
 */
extension ObjcMessageGenParser {
    var messageSend: Parser
}
