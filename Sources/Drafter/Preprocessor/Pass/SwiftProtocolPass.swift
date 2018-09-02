//
//  SwiftProtocolPass.swift
//  Drafter
//
//  Created by LZephyr on 2018/9/2.
//

import Foundation

/// 在Parse的时候可能会将swift的Protocol识别成Super Class，这这里对Swift的protocol做一次筛选
class SwiftProtocolPass: Pass {
    func run(onOCTypes ocTypes: [ObjcTypeNode], swiftTypes: [SwiftTypeNode]) -> ([ObjcTypeNode], [SwiftTypeNode]) {
        let protocolsSet = swiftTypes.protocols.toSet { node in
            return node.name
        }
        for cls in swiftTypes.classes {
            // SuperCls应该是该类型的Protocol
            if let superName = cls.superCls, protocolsSet.contains(superName) {
                cls.superCls = nil
                cls.protocols.append(superName)
            }
        }
        
        return (ocTypes, swiftTypes)
    }
}
