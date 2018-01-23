//
//  Parser.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

enum ParserError: Error {
    case missMatch(String)
    case custom(String)
    case unknown
}

// AST节点
protocol Node {
    func toJson() -> String // 将结果转换成JSON的描述
}

protocol ParserType {
    associatedtype T
    var parser: Parser<T> { get }
}

extension Node {
    func toJson() -> String {
        fatalError("Error: toJson() method not implement!")
        return ""
    }
}
