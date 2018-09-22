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
        return mergeProtocolMethod(files).map({ (file) -> FileNode in
            // 头文件Interface方法的访问权限为public
                if file.type == .h {
                for interface in file.objcTypes.interfaces {
                    for method in interface.methods {
                        method.accessControl = .public
                    }
                }
            }
            // 如果swift的extension和class定义了访问权限, 其方法不能超过上层的权限
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

    /// 将Interface继承的Protocol方法合并到Interface中
    func mergeProtocolMethod(_ files: [FileNode]) -> [FileNode] {
        let ocProtocols = files.ocTypes.protocols.toDictionary({ $0.name })
        for interface in files.ocTypes.interfaces {
            for protoName in interface.protocols {
                interface.methods.append(contentsOf: getMethods(in: ocProtocols[protoName], all: ocProtocols))
            }

        }
        return files
    }

    /// 获取一个Protocol中所有的方法（包括它父协议）
    func getMethods(in target: ProtocolNode?, all: [String: ProtocolNode]) -> [MethodNode] {
        guard let name = target?.name, let proto = all[name] else {
            return []
        }
        return proto.supers.reduce(proto.methods) { (methods, superName) -> [MethodNode] in
            return methods + self.getMethods(in: all[superName], all: all)
        }
    }
}
