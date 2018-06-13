//
//  ExtensionNode.swift
//  Drafter
//
//  Created by LZephyr on 2018/5/27.
//

import Foundation

/// Swift的Extension
class ExtensionNode: Node {
    var name: String = "" // 类型的名字
    var protocols: [String] = [] // 实现的协议
    var methods: [MethodNode] = [] // 方法
    
    // sourcery:inline:ExtensionNode.AutoCodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        protocols = try container.decode([String].self, forKey: .protocols)
        methods = try container.decode([MethodNode].self, forKey: .methods)
    }
    init() { }
    // sourcery:end
}

extension ExtensionNode {
    convenience init(_ name: String, _ protos: [String]?, _ methods: [MethodNode]) {
        self.init()
        self.name = name
        self.protocols = protos ?? []
        self.methods = methods
    }
}
