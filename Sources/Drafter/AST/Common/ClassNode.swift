//
//  NodeConstant.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/26.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Cocoa

/// 保存类型信息的节点
class ClassNode: Node {
    var isSwift: Bool = false      // 是否为swift
    var superCls: String? = nil    // 父类
    var className: String = ""     // 类名
    var protocols: [String] = []   // 实现的协议
    var methods: [MethodNode] = [] // 方法
    var accessControl: AccessControlLevel = .public // 访问权限
    
    // sourcery:inline:ClassNode.AutoCodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSwift = try container.decode(Bool.self, forKey: .isSwift)
        superCls = try container.decode(String?.self, forKey: .superCls)
        className = try container.decode(String.self, forKey: .className)
        protocols = try container.decode([String].self, forKey: .protocols)
        methods = try container.decode([MethodNode].self, forKey: .methods)
        accessControl = try container.decode(AccessControlLevel.self, forKey: .accessControl)
    }
    init() { }
    // sourcery:end
}

// MARK: - 自定义初始化方法

extension ClassNode {
    convenience init(_ isSwift: Bool, _ accessLevel: String?, _ name: String, _ superClass: String?, _ protos: [String], _ methods: [MethodNode]) {
        self.init()
        
        if let superClass = superClass, !superClass.isEmpty {
            self.superCls = superClass
        }
        self.isSwift = isSwift
        self.className = name
        self.protocols = protos
        self.methods = methods
        self.accessControl = AccessControlLevel(stringLiteral: accessLevel ?? "internal")
    }
    
    convenience init(clsName: String) {
        self.init(false, nil, clsName, nil, [], [])
    }
    
    // 解析OC时所用的初始化方法
    convenience init(interface: InterfaceNode? = nil, implementation: ImplementationNode? = nil) {
        self.init()
        
        self.isSwift = false
        if let interface = interface {
            self.className = interface.className
            self.superCls = interface.superCls ?? ""
            self.protocols = interface.protocols
        }
        
        if let imp = implementation {
            let interfaceMethods = Set<MethodNode>(interface?.methods ?? [])
            /// 作用域
            self.methods = imp.methods.map { method -> MethodNode in
                if let index = interfaceMethods.index(of: method) {
                    method.accessControl = max(method.accessControl, interfaceMethods[index].accessControl)
                }
                return method
            }
        }
    }
}

// MARK: - 数据格式化

extension ClassNode: CustomStringConvertible {
    var description: String {
        var desc = "{class: \(className)"
        
        if let superCls = superCls {
            desc.append(contentsOf: ", superClass: \(superCls)")
        }
        
        if protocols.count > 0 {
            desc.append(contentsOf: ", protocols: \(protocols.joined(separator: ", "))")
        }
        
        desc.append(contentsOf: "}")
        return desc
    }
}

extension ClassNode {
    /// 转换成前端模板用的JSON数据
    func toTemplateJSON() -> [String: Any] {
        var info = [String: Any]()
        let methodIds = self.methods.map { $0.hashValue }
        let clsId = ID_MD5(className)
        
        info["type"] = "class"              // type
        info["name"] = className            // name
        if let superClass = superCls {      // super
            info["super"] = superClass
        } else {
            info["super"] = ""
        }

        info["accessControl"] = accessControl.description // access level
        info["protocols"] = protocols.map { ["name": $0, "id": ID_MD5($0)] }  // protocols
        info["isSwift"] = isSwift           // isSwift
        info["id"] = clsId                  // id

        // 以方法的id作为Key转换成字典
        info["methods"] =                   // methods
            methods.map {
                $0.toTemplateJSON(clsId: clsId, methods: methodIds)
            }
            .toDictionary({ (json) -> String? in
                return json["id"] as? String
            })
        
        return info
    }
}

// MARK: - Hashable

extension ClassNode: Hashable {
    static func ==(lhs: ClassNode, rhs: ClassNode) -> Bool {
        return lhs.className == rhs.className
    }
    
    var hashValue: Int {
        return className.hashValue
    }
}
