//
//  Operator.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/5.
//

import Foundation

func <?> <T>(_ parser: Parser<T>, _ err: String) -> Parser<T> {
    return Parser<T> { (tokens) -> Result<(T, Tokens)> in
        let result = parser.parse(tokens)
        if case .failure(let error) = result {
            return .failure(.custom("\(err): \(error)"))
        }
        return result
    }
}

/// parser结果为可选值，如果parser成功但结果为空则用defaultVal替换结果
func ?? <T>(_ parser: Parser<T?>, _ defaultVal: T) -> Parser<T> {
    return Parser<T> { (tokens) -> Result<(T, Tokens)> in
        switch parser.parse(tokens) {
        case .success(let (result, rest)):
            if let result = result {
                return .success((result, rest))
            } else {
                return .success((defaultVal, rest))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - 类型转换操作符

/// => 是一个将Parser<T>转换成指定类型的操作符
func => <T, U>(_ lhs: Parser<T>, _ transfrom: @escaping (T) -> U) -> Parser<U> {
    return lhs.map { transfrom($0) }
}

func => <T, U>(_ lhs: Parser<[T]>, _ transfrom: @escaping (T) -> U) -> Parser<[U]> {
    return lhs.map { list in
        list.map { transfrom($0) }
    }
}

func => <T, U>(_ lhs: Parser<[T]?>, _ transfrom: @escaping (T) -> U) -> Parser<[U]> {
    return lhs.map { list in
        if let list = list {
            return list.map { transfrom($0) }
        } else {
            return []
        }
    }
}

// MARK: - 类型转换辅助方法

/// 将所有Token的text组合成一个字符串
let joinedText: ([Token]) -> String = { tokens in
    var strings = [String]()
    for token in tokens {
        strings.append(token.text)
    }
    return strings.joined()
}

/// 将所有Token的text组合成一个字符串, 以separator作为分隔符
func joinedText(_ separator: String) -> ([Token]) -> String {
    return { tokens in
        var strings = [String]()
        for token in tokens {
            strings.append(token.text)
        }
        return strings.joined(separator: separator)
    }
}

/// 将所有text组合成一个字符串, 以separator作为分隔符
func joinedText(_ separator: String) -> ([String]) -> String {
    return { texts in
        return texts.joined(separator: separator)
    }
}

/// 提取Token的text字段
var stringify: (Token?) -> String {
    return { token in
        if let token = token {
            return token.text
        } else {
            return ""
        }
    }
}

/// 接收任意参数，包装在数组中返回
func array<T>() -> (T) -> [T] {
    return { t in
        [t]
    }
}
