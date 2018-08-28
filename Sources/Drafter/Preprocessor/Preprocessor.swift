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
    
    func process(_ nodes: [FileNode]) -> [ClassNode] {
        return []
    }
    
    func register(pass: Pass) {
        
    }
}
