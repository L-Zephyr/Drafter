//
//  ObjcTypeNode.swift
//  Drafter
//
//  Created by LZephyr on 2018/8/28.
//

import Foundation

/// OC的类型
enum ObjcTypeNode: Node {
    case interface(InterfaceNode)
    case implementaion(ImplementationNode)
}

// MARK: -

extension Array where Element == ObjcTypeNode {
    /// 取出所有的InterfaceNode
    var interfaces: [InterfaceNode] {
        return self.compactMap {
            if case .interface(let node) = $0 {
                return node
            }
            return nil
        }
    }
    
    /// 取出所有的ImplementationNode
    var implementations: [ImplementationNode] {
        return self.compactMap {
            if case .implementaion(let node) = $0 {
                return node
            }
            return nil
        }
    }
}
