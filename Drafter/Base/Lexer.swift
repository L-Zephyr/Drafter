//
//  Lexer.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

enum LexerError: Error {
    case notMatch
}

class Lexer {
    
    // 通过具体内容初始化
    init(input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    // 通过文件路径初始化
    init(file: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: file))
            input = String(data: data, encoding: .utf8) ?? ""
        } catch {
            print(error)
            input = ""
        }
        
        index = input.startIndex
    }
    
    /// 获取下一个Token
    var nextToken: Token {
        while index != input.endIndex {
            let c = input[index]
            
            switch c {
            case " ", "\t", "\n", "\r": // 跳过空白符
                skipWhitespace()
                continue
                
            case "(":
                consume()
                return Token(type: .leftParen, text: "(")
                
            case ")":
                consume()
                return Token(type: .rightParen, text: ")")
                
            case "[":
                consume()
                return Token(type: .leftSquare, text: "[")
                
            case "]":
                consume()
                return Token(type: .rightSquare, text: "]")
                
            case "<":
                consume()
                return Token(type: .leftBrace, text: "<")
                
            case ">":
                consume()
                return Token(type: .rightBrace, text: ">")
                
            case ":":
                consume()
                return Token(type: .colon, text: ":")
                
            case ",":
                consume()
                return Token(type: .comma, text: ",")
                
            case ";":
                consume()
                return Token(type: .semicolon, text: ";")
                
            case "+":
                consume()
                return Token(type: .plus, text: "+")
                
            case "-":
                consume()
                return Token(type: .minus, text: "-")
                
            case "*":
                consume()
                return Token(type: .asterisk, text: "*")
                
            case "@":
                let token = atSign()
                if token.type != .unknown {
                    return token
                } else { // 无法解析当前符号则继续解析
                    fallthrough
                }
                
            default:
                if isLetter(c) || c == "_" {
                    // TODO: 考虑保留字的处理
                    let value = name()
                    return Token(type: .name, text: "\(value)")
                }
                consume()
                continue
            }
        }
        
        return Token(type: .endOfFile, text: "")
    }
    
    // MARK: - private 
    
    fileprivate var input: String = ""
    fileprivate var index: String.Index
    
    /// 获取当前位置的字符
    fileprivate var currentChar: Character {
        return input[index]
    }
    
    /// 是否到达文件的结尾
    fileprivate var fileEnd: Bool {
        return index == input.endIndex
    }
    
    /// 步进到下一个位置
    fileprivate func consume() {
        index = input.index(after: index)
    }
    
    /// 跳过所有的空白符
    fileprivate func skipWhitespace() {
        let ws = [" ", "\t", "\n", "\r"]
        while !fileEnd && ws.contains(String(currentChar)) {
            consume()
        }
    }
}

// MARK: - 辅助解析方法

fileprivate extension Lexer {
    
    /// 解析一个变量名称
    func name() -> String {
        guard !fileEnd else {
            return ""
        }
        
        var name: [Character] = []
        var c: Character
        
        while !fileEnd {
            c = currentChar
            if isLetter(c) || isNumber(c) || c == "_" {
                name.append(c)
                consume()
            } else {
                break
            }
        }
        
        return String(name)
    }
    
    /// 解析@符号
    func atSign() -> Token {
        if interface() { // 匹配'@interface '成功
//            skipWhitespace() // 跳过中间的空白符，继续解析名称
//            if !fileEnd && isLetter(currentChar) {
//                let clsName = name()
//                return Token(type: .interface(name: clsName), text: "@interface \(clsName)")
//            } else {
//                return Token(type: .unknown, text: "") // 没有名称则匹配失败
//            }
            return Token(type: .interface, text: "@interface")
        } else if implementation() {
//            skipWhitespace() // 跳过中间的空白符，继续解析名称
//            if !fileEnd && isLetter(currentChar) {
//                let clsName = name()
//                return Token(type: .implementation(name: clsName), text: "@implementation \(clsName)")
//            } else {
//                return Token(type: .unknown, text: "") // 没有名称则匹配失败
//            }
            return Token(type: .implementation, text: "@implementation")
        } else if end() {
            return Token(type: .end, text: "@end")
        }
        
        return Token(type: .unknown, text: "")
    }
    
    /// 字符是否为字母
    func isLetter(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z")
    }
    
    /// 字符是否为数字
    func isNumber(_ c: Character) -> Bool {
        return (c >= "0" && c <= "9")
    }
}

// MARK: - 匹配

fileprivate extension Lexer {
    
    /// 匹配指定的名称
    func match(_ name: String) throws {
        var i = name.startIndex
        
        while i != name.endIndex && !fileEnd {
            if name[i] != currentChar {
                throw LexerError.notMatch
            }
            
            i = name.index(after: i)
            consume()
        }
        
        // 说明到达文件结尾了
        if i != name.endIndex {
            throw LexerError.notMatch
        }
    }
    
    /// 匹配@interface声明, 包括后面的空白符
    func interface() -> Bool {
        let start = index
        do {
            try match("@interface")
            try whitespace()
            
            return true
        } catch {
            index = start // 匹配失败则将重置位置
            return false
        }
    }
    
    /// 匹配@implementation
    func implementation() -> Bool {
        let start = index
        do {
            try match("@implementation")
            try whitespace()
            return true
        } catch {
            index = start
            return false
        }
    }
    
    func end() -> Bool {
        let start = index
        do {
            try match("@end")
            try whitespace()
            return true
        } catch {
            index = start
            return false
        }
    }
    
    /// 是否为空白符号, 如果当前已到达文件末尾视为匹配成功
    func whitespace() throws {
        if !fileEnd {
            switch currentChar {
            case " ", "\t", "\n", "\r":
                consume()
                break
            default:
                throw LexerError.notMatch
            }
        }
    }
}
