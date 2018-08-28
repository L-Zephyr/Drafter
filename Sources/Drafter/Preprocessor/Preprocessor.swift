//
//  Preprocessor.swift
//  Drafter
//
//  Created by LZephyr on 2018/8/28.
//

import Foundation

protocol Pass {
    associatedtype N: Node
    func run(with nodes: [N]) -> [N]
}


/// 对AST进行预处理
class Preprocessor {
    static let shared = Preprocessor()
    
    func process(_ nodes: [FileNode]) -> [ClassNode] {
        return []
    }
    
    func register<P: Pass>(pass: P) {
        
    }
}


class InterfacePass: Pass {
    func run(with nodes: [InterfaceNode]) -> [InterfaceNode] {
        return nodes
    }
}
