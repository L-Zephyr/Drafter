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
    
    // sourcery:inline:ImplementationNode.AutoCodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        className = try container.decode(String.self, forKey: .className)
        methods = try container.decode([MethodNode].self, forKey: .methods)
    }
    init() { }
    // sourcery:end
}

extension ImplementationNode {
    convenience init(_ clsName: String, _ methods: [MethodNode]) {
        self.init()
        
        self.className = clsName
        self.methods = methods
    }
}
