//
//  ObjcMethodNode.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/27.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 代表OC的方法定义
class ObjcMethodNode: Node {
    var isStatic = false  // 是否为类方法
    var returnType: String = "" // 返回值类型
    var params: [Param] = [] // 方法的参数
    var invokes: [ObjcMessageNode] = [] // 该方法中调用的OC方法
    var methodBody: [Token] = [] // 函数体的源码
}

extension ObjcMethodNode: CustomStringConvertible {
    var description: String {
        var method = "["
        
        for param in params {
            method.append(contentsOf: param.outterName)
            if !param.innerName.isEmpty {
                method.append(contentsOf: ":(\(param.type))\(param.innerName) ")
            }
        }
        
        method.append(contentsOf: "]")
        
        return method
    }
}

struct Param: Node {
    var type: String = "" // 参数类型
    var outterName: String = "" // 参数的名字
    var innerName: String = "" // 内部形参的名字
}

extension Param {
    init(type: String, outter: String, inner: String) {
        self.init()
        self.type = type
        self.outterName = outter
        self.innerName = inner
    }
}
