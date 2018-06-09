//
//  ConcreteParserType.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// AST节点
protocol Node: AutoCodable {
    
}

// 具体的Parser类型
protocol ConcreteParserType {
    associatedtype T
    var parser: Parser<T, Tokens> { get }
}
