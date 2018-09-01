//
//  Preprocessor.swift
//  Drafter
//
//  Created by LZephyr on 2018/8/28.
//

import Foundation

// MARK: - Pass

/// 定义了三个协议方法，对应预处理的三个阶段
protocol Pass {
    // 1. 对各个文件节点的预处理
    func run(onFiles: [FileNode]) -> [FileNode]
    // 2. 取出所有oc和swift类型后进行预处理
    func run(onOCTypes: [ObjcTypeNode], swiftTypes: [SwiftTypeNode]) -> ([ObjcTypeNode], [SwiftTypeNode])
    // 3. 将oc和swift类型合并成ClassNode后的处理
    func run(onClasses: [ClassNode]) -> [ClassNode]
}

extension Pass {
    func run(onFiles files: [FileNode]) -> [FileNode] {
        return files
    }
    
    func run(onOCTypes ocTypes: [ObjcTypeNode], swiftTypes: [SwiftTypeNode]) -> ([ObjcTypeNode], [SwiftTypeNode]) {
        return (ocTypes, swiftTypes)
    }
    
    func run(onClasses classes: [ClassNode]) -> [ClassNode] {
        return classes
    }
}

// MARK: - Preprocessor

/// 对AST进行预处理
class Preprocessor {
    static let shared = Preprocessor()
    
    /// 对Parser解析出来的AST进行预处理
    ///
    /// - Parameter nodes: 解析器解析出来的所有语法节点
    /// - Returns: 经过处理后返回[ClassNode]来生成前端模板
    func process(_ nodes: [FileNode]) -> [ClassNode] {
        // 1. 基于文件的处理
        let files = passList.reduce(nodes, { files, pass in
            return pass.run(onFiles: files)
        })
        
        // 2. 处理OC和Swift类型
        let (ocTypes, swiftTypes) = passList.reduce((files.ocTypes, files.swiftTypes), { types, pass in
            return pass.run(onOCTypes: types.0, swiftTypes: types.1)
        })
        
        // 3. 整合成ClassNode
        let imps = ocTypes.implementations.toDictionary { $0.className }
        let ocClasses = ocTypes.interfaces.compactMap { interface -> ClassNode? in
            if let imp = imps[interface.className] {
                return ClassNode(interface: interface, implementation: imp)
            }
            return nil
        }
        let classList = ocClasses + swiftTypes.classes
        
        return passList.reduce(classList, { list, pass in
            return pass.run(onClasses: list)
        })
    }
    
    /// 注册一个Pass
    ///
    /// - Parameter pass: 一个Pass实例
    func register(pass: Pass) {
        passList.append(pass)
    }
    
    // MARK: - Private
    
    fileprivate var passList: [Pass] = []
}
