//
//  ProtocolNode.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

class ProtocolNode: Node {
    var name: String = ""
    var supers: [String] = []
    var methods: [MethodNode] = []
    
    // sourcery:inline:ProtocolNode.AutoCodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        supers = try container.decode([String].self, forKey: .supers)
        methods = try container.decode([MethodNode].self, forKey: .methods)
    }
    init() { }
    // sourcery:end
}

extension ProtocolNode {
    convenience init(_ name: String, _ supers: [String]?, _ methods: [MethodNode]) {
        self.init()
        self.name = name
        self.supers = supers ?? []
        self.methods = methods
    }
}

extension ProtocolNode: Hashable {
    
    static func ==(_ left: ProtocolNode, _ right: ProtocolNode) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    var hashValue: Int {
        return name.hashValue
    }
}
