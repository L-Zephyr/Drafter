//
//  SwiftType.swift
//  Drafter
//
//  Created by LZephyr on 2018/5/27.
//

import Foundation

enum SwiftType: Node {
    case `class`(ClassNode)
    case `extension`(ExtensionNode)
}

extension Array where Element == SwiftType {
//    /// 过滤出所有class类型
//    func classList() -> [ClassNode] {
//        return self.flatMap { type in
//            if case .class(let node) = type {
//                return [node]
//            }
//            return []
//        }
//    }
//
//    /// 过滤出所有Extension类型
//    func extensionList() -> [ExtensionNode] {
//        return self.flatMap { type in
//            if case .extension(let node) = type {
//                return [node]
//            }
//            return []
//        }
//    }
}
