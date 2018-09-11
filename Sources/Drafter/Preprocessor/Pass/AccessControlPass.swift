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
            // 头文件Interface方法的访问权限为public
            if file.type == .h {
                for interface in file.objcTypes.interfaces {
                    for method in interface.methods {
                        method.accessControl = .public
                    }
                }
            }
            // 如果swift的extension和class定义了访问权限
            if file.type == .swift {
                for ext in file.swiftTypes.extensions {
                    for method in ext.methods where method.accessControl > ext.accessControl {
                        method.accessControl = ext.accessControl
                    }
                }
                for cls in file.swiftTypes.classes {
                    for method in cls.methods where method.accessControl > cls.accessControl {
                        method.accessControl = cls.accessControl
                    }
                }
            }
            return file
        })
    }
}
