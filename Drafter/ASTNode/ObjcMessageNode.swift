//
//  ObjcMessageNode.swift
//  Drafter
//
//  Created by LZephyr on 2017/9/28.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

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
        
        for param in params {
            method.append(contentsOf: "\(param) ")
        }
        
        method.append(contentsOf: "]")
        
        return method
    }
}

enum ObjcMessageReceiver {
    case name(String)    // 普通变量
    case message(ObjcMessageNode) // 另一个方法调用
}
