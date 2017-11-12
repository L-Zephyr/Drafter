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
    case statical         // 静态声明关键字: static
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
    case equal             // 等号: =
    case underline         // 下划线: _
    case plus              // 加号: +
    case minus             // 减号: -
    case asterisk          // 星号: *
    case doubleQuote       // 双引号: "
    case backslash         // 反斜线: \
    case caret             // 脱字符: ^
    case dot               // 点号: .
    case at                // @
    case rightArrow        // 箭头: ->
    
    // MARK: - swift特有符号
    
    case cls              // swift的class关键字
    case proto            // swift的protocol关键字
    case exten            // swift的extension关键字
    case structure        // swift的struct关键字
    case function         // swift的func关键字
    case autoclosure       // @autoclosure
    case `inout`          // inout
    case `throw`          // throws、rethrows
}

// MARK: - 词法单元类型

struct Token {
    var type: TokenType
    var text: String
    
    init(type: TokenType, text: String) {
        self.type = type
        self.text = text
    }
}

extension Token: Equatable {
    static func ==(lhs: Token, rhs: Token) -> Bool {
        if lhs.type == .name && rhs.type == .name {
            return lhs.text == rhs.text
        } else {
            return lhs.type == rhs.type
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        return "\(text)"
    }
}
