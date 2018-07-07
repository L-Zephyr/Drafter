//
//  SwiftTypeNode.swift
//  Drafter
//
//  Created by LZephyr on 2018/5/27.
//

import Foundation

/// 用来表示Swift中自定义的类型
/// 目前支持：class、protocol、extension
enum SwiftTypeNode: Node {
    case `class`(ClassNode)
    case `protocol`(ProtocolNode)
    case `extension`(ExtensionNode)
}

// MARK: -

extension Array where Element == SwiftTypeNode {
    /// 过滤出所有class类型
    var classes: [ClassNode] {
        return self.compactMap { type in
            if case .class(let node) = type {
                return node
            }
            return nil
        }
    }

    /// 过滤出所有Extension类型
    var extensions: [ExtensionNode] {
        return self.compactMap { type in
            if case .extension(let node) = type {
                return node
            }
            return nil
        }
    }

    /// 过滤出所有Protocol类型节点
    var protocols: [ProtocolNode] {
        return self.compactMap { type in
            if case .protocol(let node) = type {
                return node
            }
            return nil
        }
    }
}
