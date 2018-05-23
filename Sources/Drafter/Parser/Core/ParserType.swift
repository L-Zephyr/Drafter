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
protocol Node: AutoCodable {
    
}

protocol ParserType {
    associatedtype T
    var parser: Parser<T> { get }
}

//extension Node {
//    // 将结果节点转换成JSON格式
//    func toTemplateJSON() -> String {
//        fatalError("Error: toTemplateJSON() method not implement!")
//    }
//}

