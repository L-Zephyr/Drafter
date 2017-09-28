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
    var receiver: String = "" // 方法接收者
    var params: [String] = [] // 参数
}
