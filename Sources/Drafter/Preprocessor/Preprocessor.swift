//
//  Preprocessor.swift
//  Drafter
//
//  Created by LZephyr on 2018/8/28.
//

import Foundation

protocol Pass {
    func run(onFiles: [FileNode]) -> [FileNode]
}

extension Pass {
    func run(onFiles files: [FileNode]) -> [FileNode] {
        return files
    }
}


/// 对AST进行预处理
class Preprocessor {
    static let shared = Preprocessor()
    
    /// 对Parser解析出来的AST进行预处理
    ///
    /// - Parameter nodes: 解析器解析出来的所有语法节点
    /// - Returns: 经过处理后返回[ClassNode]来生成前端模板
    func process(_ nodes: [FileNode]) -> [ClassNode] {
        return []
    }
    
    /// 注册一个Pass
    ///
    /// - Parameter pass: 一个Pass实例
    func register(pass: Pass) {
        
    }
}
