//
//  MethodInvokeNode.swift
//  Drafter
//
//  Created by LZephyr on 2017/9/28.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - MethodInvoker

enum MethodInvoker {
    case name(String)    // 普通变量
    case method(MethodInvokeNode) // 另一个方法调用
}

// MARK: - MethodInvokeNode

/// 方法调用
class MethodInvokeNode: Node {
    var isSwift: Bool = false
    var invoker: MethodInvoker = .name("") // 该方法的调用者
    var methodName: String = "" // 只有解析swift用到这个属性
    var params: [String] = [] // 参数, 只记录参数名称
}

extension MethodInvokeNode {
    convenience init(_ isSwift: Bool, _ invoker: MethodInvoker, _ methodName: String, _ params: [String]) {
        self.init()
        self.isSwift = isSwift
        self.invoker = invoker
        self.params = params
        self.methodName = methodName
    }
}

extension MethodInvokeNode {
    
    /// 找到最上层的调用者
    var topInvoker: MethodInvokeNode {
        switch invoker {
        case .name(_):
            return self
        case .method(let invoke):
            return invoke.topInvoker
        }
    }
}

// MARK: - CustomStringConvertible

extension MethodInvokeNode: CustomStringConvertible {
    var description: String {
        if isSwift {
            return swiftDescription
        } else {
            return objcDescription
        }
    }
    
    /// 格式化成OC风格的表示
    var objcDescription: String {
        var method = "["
        
        switch invoker {
        case .method(let msg):
            method.append(contentsOf: "\(msg.objcDescription) ")
        case .name(let name):
            method.append(contentsOf: "\(name) ")
        }
        
        method.append(contentsOf: "\(params.joined(separator: " "))]")
        
        return method
    }
    
    /// 格式化成swift风格的表示
    var swiftDescription: String {
        var method = ""
        
        switch invoker {
        case .method(let invoke):
            method.append(contentsOf: "\(invoke.swiftDescription).")
        case .name(let name):
            if !name.isEmpty {
                method.append(contentsOf: "\(name).")
            }
        }
        
        method.append(contentsOf: "\(methodName)(\(params.joined(separator: ", ")))")
        
        return method
    }
}

// MARK: - Hashable

extension MethodInvokeNode: Hashable {
    
    static func ==(_ left: MethodInvokeNode, _ right: MethodInvokeNode) -> Bool {
        return left.hashValue == right.hashValue
    }
    
    /// 目前swift和oc之间不能判等
    var hashValue: Int {
        if isSwift {
            return swiftHashValue
        } else {
            return objcHashValue
        }
    }
    
    var objcHashValue: Int {
        return params.joined().hashValue
    }
    
    var swiftHashValue: Int {
        let paramSign = params.joined(separator: ",")
        let methodSign = "\(methodName)\(paramSign)"
        
        return methodSign.hashValue
    }
}
