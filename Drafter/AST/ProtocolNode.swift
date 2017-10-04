//
//  ProtocolNode.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 目前该类只有swift的parser会用到
class ProtocolNode: Node {
    var name: String = ""
    var supers: [String] = []
}

extension ProtocolNode: Hashable {
    
    static func ==(_ left: ProtocolNode, _ right: ProtocolNode) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    var hashValue: Int {
        return name.hashValue
    }
}
