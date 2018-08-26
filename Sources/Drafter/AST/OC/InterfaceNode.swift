//
//  InterfaceNode.swift
//  Drafter
//
//  Created by LZephyr on 2018/1/24.
//

import Foundation

class InterfaceNode: Node {
    var superCls: String? = nil    // 父类
    var className: String = ""     // 类名
    var protocols: [String] = []   // 实现的协议
    var methods: [MethodNode] = [] // 定义的方法
    
    // sourcery:inline:InterfaceNode.AutoCodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        superCls = try container.decode(String?.self, forKey: .superCls)
        className = try container.decode(String.self, forKey: .className)
        protocols = try container.decode([String].self, forKey: .protocols)
        methods = try container.decode([MethodNode].self, forKey: .methods)
    }
    init() { }
    // sourcery:end
}

extension InterfaceNode {
    convenience init(_ clsName: String, _ superCls: String?, _ protocols: [String], _ methods: [MethodNode]) {
        self.init()
        
        self.superCls = superCls ?? ""
        self.className = clsName
        self.protocols = protocols
        self.methods = methods
    }
}

// MARK: - Hashable

extension InterfaceNode: Hashable {
    static func ==(lhs: InterfaceNode, rhs: InterfaceNode) -> Bool {
        return lhs.className == rhs.className
    }
    
    var hashValue: Int {
        return className.hashValue
    }
}
