//
//  SwiftParser.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2017/11/20.
//

import Foundation

fileprivate enum Intermediate {
    case proto(ProtocolNode)
    case cls(ClassNode)
}

extension Array where Element == Intermediate {
    // 按类型分成两个数组
    func separate() -> ([ProtocolNode], [ClassNode]) {
        var protocols = [ProtocolNode]()
        var classes = [ClassNode]()
        for item in self {
            if case .proto(let node) = item {
                protocols.append(node)
            } else if case .cls(let node) = item {
                classes.append(node)
            }
        }
        return (protocols, classes)
    }
}

// MARK: - SwiftParser

// 在一个pass中将所有的Class和Protocol节点解析出来
class SwiftParser: ConcreteParserType {
    var parser: TokenParser<([ProtocolNode], [ClassNode])> {
        // 合并protocol和class的解析结果
        return inheritParser.map { (result) -> ([ProtocolNode], [ClassNode]) in
            var (protocols, classes) = result.separate()
            classes = classes.merged()
            
            var set = Set<String>()
            for proto in protocols {
                set.insert(proto.name)
            }
            for cls in classes {
                if let name = cls.superCls, set.contains(name) {
                    cls.superCls = nil
                    cls.protocols.insert(name, at: 0)
                }
            }
            return (protocols, classes)
        }
    }
}

fileprivate extension SwiftParser {
    var inheritParser: TokenParser<[Intermediate]> {
        let intermediate =
            curry(Intermediate.proto) <^> SwiftProtocolParser().protocolParser
            <|> curry(Intermediate.cls) <^> SwiftClassParser().classParser
        return intermediate.continuous
    }
}
