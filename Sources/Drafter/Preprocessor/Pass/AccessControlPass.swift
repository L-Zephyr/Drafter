//
//  AccessControlPass.swift
//  Drafter
//
//  Created by LZephyr on 2018/9/2.
//

import Foundation

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
