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
    case unknown         // 未知类型
    case endOfFile       // 文件结束
    case interface       // @interface
    case implementation  // @implementation
    case end              // @end
    case name            // 名称 (包括变量、类名、方法等所有名称)
    case lRoundBrack      // 左圆括号: (
    case rRoundBrack      // 右圆括号: )
    case lSquareBrack     // 左方括号: [
    case rSquareBrack     // 右方括号: ]
    case lAngleBrack      // 左尖括号: <
    case rAngleBrack      // 右尖括号: >
    case colon            // 冒号: :
    case comma            // 逗号: ,
}

//extension TokenType: Equatable {
//    static func == (_ left: TokenType, _ right: TokenType) -> Bool {
//        switch (left, right) {
//        case (.unknown, .unknown): fallthrough
//        case (.endOfFile, .endOfFile): fallthrough
//        case (.lRoundBrack, .lRoundBrack): fallthrough
//        case (.rRoundBrack, .rRoundBrack): fallthrough
//        case (.lSquareBrack, .lSquareBrack): fallthrough
//        case (.rSquareBrack, .rSquareBrack): fallthrough
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
