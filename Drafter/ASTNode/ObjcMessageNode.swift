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

enum ObjcMessageReceiver {
    case name(String)    // 普通变量
    case message(ObjcMessageNode) // 另一个方法调用
}
