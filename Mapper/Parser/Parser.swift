//
//  Parser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

enum ParserError: Error {
    case notMatch(String)
}

protocol Node { } // 语法节点

protocol Parser {
    func parse() throws // 执行解析，解析失败则抛出相应错误
}
