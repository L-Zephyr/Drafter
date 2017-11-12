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

protocol Lexer {
    var nextToken: Token { get } // 获取Token
}

extension Lexer {
    /// 获取所有的Token
    var allTokens: [Token] {
        var result = [Token]()
        var next = self.nextToken
        
        while next.type != .endOfFile {
            result.append(next)
            next = self.nextToken
        }
        return result
    }
}

// MARK: - TokenLexer

class TokenLexer: Lexer {
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    var nextToken: Token {
        if index != tokens.count {
            let token = tokens[index]
            index += 1
            return token
        }
        return Token(type: .endOfFile, text: "")
    }
    
    fileprivate var index: Int = 0
    fileprivate var tokens: [Token] = []
}

// MARK: - SourceLexer

/// 解析源码的Lexer
class SourceLexer: Lexer {
    // MARK: - 初始化方法
    
    /// 通过具体内容初始化
    init(input: String, isSwift: Bool = false) {
        self.isSwift = isSwift
        self.input = SourceLexer.removeAnnotaion(input)
        self.index = input.startIndex
    }
    
    /// 通过文件路径初始化
    init(file: String) {
        isSwift = file.hasSuffix(".swift")
        do {
            let content = try String(contentsOf: URL(fileURLWithPath: file), encoding: .utf8)
            input = SourceLexer.removeAnnotaion(content)
        } catch {
            print(error)
            input = ""
        }
        
        index = input.startIndex
    }
    
    /// 直接通过Token列表初始化
//    init(tokens: [Token]) {
//        self.tokens = tokens
//    }
    
    // MARK: - 获取Token
    
    /// 获取下一个Token
    var nextToken: Token {
        while index != input.endIndex {
            switch currentChar {
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
                
            case "{":
                consume()
                return Token(type: .leftBrace, text: "{")
                
            case "}":
                consume()
                return Token(type: .rightBrace, text: "}")
                
            case "<":
                consume()
                return Token(type: .leftAngle, text: "<")
                
            case ">":
                consume()
                return Token(type: .rightAngle, text: ">")
                
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
                if currentChar == ">" {
                    consume()
                    return Token(type: .rightArrow, text: "->")
                }
                return Token(type: .minus, text: "-")
                
            case "=":
                consume()
                return Token(type: .equal, text: "=")
                
            case "*":
                consume()
                return Token(type: .asterisk, text: "*")
                
            case "\"":
                consume()
                return Token(type: .doubleQuote, text: "\"")
                
            case "\\":
                consume()
                return Token(type: .backslash, text: "\\")
                
            case "^":
                consume()
                return Token(type: .caret, text: "^")
                
            case ".":
                consume()
                return Token(type: .dot, text: ".")
                
            case "@":
                return atSign()
                
            default:
                if isLetter(currentChar) || currentChar == "_" {
                    let value = name()
                    if isSwift, let keyword = swiftKeyword(value) {
                        return keyword
                    }
                    
                    if value == "static" {
                        return Token(type: .statical, text: "static")
                    }
                    
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
    
    fileprivate var tokens: [Token] = []
    fileprivate var isSwift: Bool = false // 是否为Swift文件
    
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
    
    /// 清理注释
    class func removeAnnotaion(_ content: String) -> String {
        let annotationBlockPattern = "/\\*[\\s\\S]*?\\*/" //匹配/*...*/这样的注释
        let annotationLinePattern = "//.*?\\n" //匹配//这样的注释
        
        let regexBlock = try! NSRegularExpression(pattern: annotationBlockPattern, options: NSRegularExpression.Options(rawValue:0))
        let regexLine = try! NSRegularExpression(pattern: annotationLinePattern, options: NSRegularExpression.Options(rawValue:0))
        var newStr = ""
        newStr = regexLine.stringByReplacingMatches(in: content, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, content.count), withTemplate: "")
        newStr = regexBlock.stringByReplacingMatches(in: newStr, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, newStr.count), withTemplate: "")
        return newStr
    }
}

// MARK: - 辅助解析方法

fileprivate extension SourceLexer {
    
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
    
    /// 尝试匹配swift中的关键字
    func swiftKeyword(_ name: String) -> Token? {
        switch name {
        case "class":
            return Token(type: .cls, text: "class")
        case "struct":
            return Token(type: .structure, text: "struct")
        case "protocol":
            return Token(type: .proto, text: "protocol")
        case "extension":
            return Token(type: .exten, text: "extension")
        case "func":
            return Token(type: .function, text: "func")
        case "inout":
            return Token(type: .`inout`, text: "inout")
        case "throws", "rethrows":
            return Token(type: .`throw`, text: "throw")
        default:
            return nil
        }
    }
    
    /// 解析@符号
    func atSign() -> Token {
        if isSwift && autoclosure() {
            return Token(type: .autoclosure, text: "@autoclosure")
        }
        
        if interface() { // 匹配'@interface '成功
            return Token(type: .interface, text: "@interface")
        } else if implementation() {
            return Token(type: .implementation, text: "@implementation")
        } else if end() {
            return Token(type: .end, text: "@end")
        }
        
        consume()
        return Token(type: .at, text: "@")
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

fileprivate extension SourceLexer {
    
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
    
    /// 尝试匹配text，成功则返回true并消耗输入，失败不消耗任何输入
    func lookahead(_ text: String) -> Bool {
        let start = index
        do {
            try match(text)
            try whitespace()
            return true
        } catch {
            index = start
            return false
        }
    }
    
    /// 匹配@interface声明, 包括后面的空白符
    func interface() -> Bool {
        return lookahead("@interface")
    }
    
    /// 匹配@implementation
    func implementation() -> Bool {
        return lookahead("@implementation")
    }
    
    func end() -> Bool {
        return lookahead("@end")
    }
    
    func autoclosure() -> Bool {
        return lookahead("@autoclosure")
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
