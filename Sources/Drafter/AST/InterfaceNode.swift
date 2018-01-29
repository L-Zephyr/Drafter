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
}

extension InterfaceNode {
    convenience init(_ clsName: String, _ superCls: String?, _ protocols: [String]) {
        self.init()
        
        self.superCls = superCls ?? ""
        self.className = clsName
        self.protocols = protocols
    }
}
