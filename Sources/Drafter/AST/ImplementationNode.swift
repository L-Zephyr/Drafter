//
//  ImplementationNode.swift
//  Drafter
//
//  Created by LZephyr on 2018/1/24.
//

import Foundation

class ImplementationNode: Node {
    var className: String = ""
    var methods: [MethodNode] = []
}

extension ImplementationNode {
    convenience init(_ clsName: String, _ methods: [MethodNode]) {
        self.init()
        
        self.className = clsName
        self.methods = methods
    }
}
