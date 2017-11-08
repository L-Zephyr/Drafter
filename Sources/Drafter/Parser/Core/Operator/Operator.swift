//
//  Operator.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/5.
//

import Foundation

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

// MARK: - 类型转换方法

/// 提取Token的text字段，将Token类型转换成String类型
var stringify: (Token?) -> String {
    return { token in
        if let token = token {
            return token.text
        } else {
            return ""
        }
    }
}
