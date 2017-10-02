//
//  ObjcMessageNode.swift
//  Drafter
//
//  Created by LZephyr on 2017/9/28.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - ObjcMessageReceiver

enum ObjcMessageReceiver {
    case name(String)    // 普通变量
    case message(ObjcMessageNode) // 另一个方法调用
}

// MARK: - ObjcMessageNode

/// OC方法调用
class ObjcMessageNode: Node {
    var receiver: ObjcMessageReceiver = .name("")
    var params: [String] = [] // 参数
}

extension ObjcMessageNode: CustomStringConvertible {
    var description: String {
        var method = "["
        
        switch receiver {
        case .message(let msg):
            method.append(contentsOf: "\(msg.description) ")
        case .name(let name):
            method.append(contentsOf: "\(name) ")
        }
        
        for index in 0..<params.count {
            method.append(contentsOf: "\(params[index])")
            if index != params.count - 1 {
                method.append(contentsOf: " ")
            }
        }
        
        method.append(contentsOf: "]")
        
        return method
    }
}

extension ObjcMessageNode: Hashable {
    
    static func ==(_ left: ObjcMessageNode, _ right: ObjcMessageNode) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    var hashValue: Int {
        var value = ""
        for param in params {
            value.append(contentsOf: param)
        }
        return value.hashValue
    }
}
