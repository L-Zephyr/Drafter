//
//  Token.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - 词法单元类型

enum TokenType {
    case unknown          // 未知类型
    case endOfFile        // 文件结束
    case interface        // @interface
    case implementation   // @implementation
    case end              // @end
    case name             // 名称 (包括变量、类名、方法等所有名称)
    case leftParen        // 左圆括号: (
    case rightParen       // 右圆括号: )
    case leftSquare       // 左方括号: [
    case rightSquare      // 右方括号: ]
    case leftBrace        // 左大括号: {
    case rightBrace        // 右大括号: }
    case leftAngle         // 左尖括号: <
    case rightAngle        // 右尖括号: >
    case colon             // 冒号: :
    case comma             // 逗号: ,
    case semicolon         // 分号: ;
    case underline         // 下划线: _
    case plus              // 加号: +
    case minus             // 减号: -
    case asterisk          // 星号: *
    case doubleQuote       // 双引号: "
    case backslash         // 反斜线: \
    case caret             // 脱字符: ^
}

//extension TokenType: Equatable {
//    static func == (_ left: TokenType, _ right: TokenType) -> Bool {
//        switch (left, right) {
//        case (.unknown, .unknown): fallthrough
//        case (.endOfFile, .endOfFile): fallthrough
//        case (.leftParen, .leftParen): fallthrough
//        case (.rightParen, .rightParen): fallthrough
//        case (.leftSquare, .leftSquare): fallthrough
//        case (.rightSquare, .rightSquare): fallthrough
//        case (.colon, .colon): fallthrough
//        case (.comma, .comma): fallthrough
//        case (.end, .end): fallthrough
//        case (.interface, .interface): fallthrough
//        case (.implementation, .implementation):
//            return true
//        case (.name(let l), .name(let r)):
//            return l == r
//        default:
//            return false
//        }
//    }
//}

// MARK: - 词法单元类型

protocol Tokenize {
    var type: TokenType { set get }
}

class Token: Tokenize {
    var type: TokenType
    var text: String
    
    init(type: TokenType, text: String) {
        self.type = type
        self.text = text
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        return "<\(text)>"
    }
}

// TODO: 这里的定义应该属于AST

// MARK: - Class Token

class ClassToken: Tokenize {
    var type: TokenType
    var superCls: ClassToken? = nil // 父类
    var protocols: [ProtocolToken] = [] // 实现的协议
    
    init(type: TokenType) {
        self.type = type
    }
}

// MARK: - Procotol Token

class ProtocolToken: Tokenize {
    var type: TokenType
    
    init(type: TokenType) {
        self.type = type
    }
}
