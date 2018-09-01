//
//  Passes.swift
//  Drafter
//
//  Created by LZephyr on 2018/9/1.
//

import Foundation

// MARK: - ScopePass

/// 处理OC的访问控制
class AccessControlPass: Pass {
    func run(onFiles files: [FileNode]) -> [FileNode] {
        return files.map({ (file) -> FileNode in
            if file.type == .h {
                for interface in file.objcTypes.interfaces {
                    for method in interface.methods {
                        method.accessControl = .public
                    }
                }
            }
            return file
        })
    }
}

// MARK: - DistinctPass

/// 合并重复类型的节点
class DistinctPass: Pass {
//    func run(onOCTypes: [ObjcTypeNode], swiftTypes: [SwiftTypeNode]) -> ([ObjcTypeNode], [SwiftTypeNode]) {
//
//    }
}
