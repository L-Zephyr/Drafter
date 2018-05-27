//
//  MethodNode.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/27.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - Param

struct Param: AutoCodable {
    var outterName: String  // 参数的名字
    var type: String  // 参数类型
    var innerName: String  // 内部形参的名字
}

// MARK: - MethodNode

/// 方法定义
class MethodNode: Node {
    var isSwift = false  // 是否为swift方法
    var isStatic = false  // 是否为类方法
    var returnType: String = "" // 返回值类型
    var methodName: String = "" // 方法的名字
    var params: [Param] = [] // 方法的参数
    var invokes: [MethodInvokeNode] = [] // 方法体中调用的方法
    
    // sourcery:inline:MethodNode.AutoCodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSwift = try container.decode(Bool.self, forKey: .isSwift)
        isStatic = try container.decode(Bool.self, forKey: .isStatic)
        returnType = try container.decode(String.self, forKey: .returnType)
        methodName = try container.decode(String.self, forKey: .methodName)
        params = try container.decode([Param].self, forKey: .params)
        invokes = try container.decode([MethodInvokeNode].self, forKey: .invokes)
    }
    init() { }
    // sourcery:end
}

// MARK: - 初始化方法

extension MethodNode {
    /// OC初始化方法
    class func ocInit(_ isStatic: Bool, _ retType: String, _ params: [Param], _ invokes: [MethodInvokeNode]) -> MethodNode {
        let method = MethodNode()
        
        method.isSwift = false
        method.isStatic = isStatic
        method.returnType = retType
        method.params = params
        method.invokes = invokes
        
        return method
    }
    
    /// swift初始化方法
    class func swiftInit(_ isStatic: Bool, _ name: String, _ params: [Param], _ retType: String, _ invokes: [MethodInvokeNode]) -> MethodNode {
        let method = MethodNode()
        
        method.isSwift = true
        method.isStatic = isStatic
        method.returnType = retType
        method.methodName = name
        method.params = params
        method.invokes = invokes
        
        return method
    }
}

// MARK: - 数据格式化

extension MethodNode: CustomStringConvertible {
    var description: String {
        if isSwift {
            return swiftDescription
        } else {
            return objcDescription
        }
    }
    
    /// 格式化成OC风格
    var objcDescription: String {
        var method = "\(isStatic ? "+" : "-") ["
        
        let methodDesc = params.join(stringify: { (param) -> String in
            if !param.innerName.isEmpty {
                return "\(param.outterName):"
            } else {
                return param.outterName
            }
        }, separator: " ")
        method.append(contentsOf: "\(methodDesc)]")
        
        return method
    }
    
    /// 格式化成swift风格
    var swiftDescription: String {
        var method = ""
        
        if methodName != "init" {
            method.append(contentsOf: "func ")
        }
        method.append(contentsOf: "\(methodName)(")
        
        if isStatic {
            method.insert(contentsOf: "static ", at: method.startIndex)
        }
        
        let paramStr = params.join(stringify: { (param) -> String in
            return "\(param.outterName.isEmpty ? "_" : param.outterName): "
        }, separator: ", ")
        method.append(contentsOf: "\(paramStr))")
        
        return method
    }
}

extension MethodNode {
    /// 将方法转化成JSON字典
    func toTemplateJSON(clsId: String, methods: [Int]) -> [String: Any] {
        var info: [String: Any] = [:]
        info["type"] = "method"                         // type
        info["classId"] = clsId                         // classId
        info["static"] = self.isStatic                  // static
        info["isSwift"] = self.isSwift                  // isSwift
        
        if isSwift {
            info["name"] = methodName                   // name
        }
        
        info["returnType"] = returnType                 // returnType
        info["id"] = ID_MD5("\(clsId)\(self.hashValue)") // 类id加上自身的id作为方法的id
        
        // 参数
        var paramInfo: [[String: String]] = []
        for param in params {
            paramInfo.append(["type": param.type, "sel": param.outterName, "name": param.innerName])
        }
        info["params"] = paramInfo                      // params
        
        // 调用的方法
        var invokeInfos: [[String: String]] = []
        var set = Set<MethodInvokeNode>() // 去重
        for invoke in invokes {
            if set.contains(invoke) {
                continue
            }
            // 如果调用的是自身的方法
            if methods.contains(invoke.hashValue) {
                invokeInfos.append([
                    "methodId": ID_MD5("\(clsId)\(invoke.hashValue)"),
                    "classId": clsId
                    ])
            } else {
                invokeInfos.append(["formatedName": invoke.description])
            }
            set.insert(invoke)
        }
        info["invokes"] = invokeInfos                   // invokes
        
        return info
    }
}

// MARK: - Hashable

extension MethodNode: Hashable {
    
    static func ==(_ left: MethodNode, _ right: MethodNode) -> Bool {
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
        var value = ""
        for param in params {
            value.append(contentsOf: param.outterName)
            if !param.innerName.isEmpty {
                value.append(contentsOf: ":")
            }
        }
        return value.hashValue
    }
    
    var swiftHashValue: Int {
        let paramSign = params.join(stringify: { (param) -> String in
            return "\(param.outterName):"
        }, separator: ",")
        let methodSign = "\(methodName)\(paramSign)"
        
        return methodSign.hashValue
    }
}
