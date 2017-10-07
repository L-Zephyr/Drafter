//
//  SwiftProtocolParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 protocol_definition = 'protocol' NAME inherit_list
 inherit_list = (':' (NAME)+ )?
 */
class SwiftProtocolParser: BacktrackParser {
    
    func parse() -> [ProtocolNode] {
        while token().type != .endOfFile {
            do {
                let proto = try protocolDefinition()
                nodes.append(proto)
            } catch {
                consume()
            }
        }
        return nodes
    }
    
    fileprivate var nodes: [ProtocolNode] = []
}

// MARK: - 规则解析

fileprivate extension SwiftProtocolParser {
    
    func protocolDefinition() throws -> ProtocolNode {
        let proto = ProtocolNode()
        
        try match(.proto)
        proto.name = try match(.name).text
        proto.supers = try inheritList()
        
        return proto
    }
    
    func inheritList() throws -> [String] {
        var inherits: [String] = []
        
        if token().type == .colon {
            try match(.colon)
            while token().type != .endOfFile {
                let parent = try match(.name).text
                inherits.append(parent)
                
                if token().type == .comma { // 还有更多
                    consume()
                } else {
                    break
                }
            }
        }
        
        return inherits
    }
}
