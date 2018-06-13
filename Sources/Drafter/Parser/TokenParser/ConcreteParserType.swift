//
//  ConcreteParserType.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation
import SwiftyParse

// AST节点
protocol Node: AutoCodable {
    
}

// 具体的Parser类型，解析特定的语法结构，对TokenParser封装
protocol ConcreteParserType {
    associatedtype T
    var parser: Parser<T, Tokens> { get }
}
