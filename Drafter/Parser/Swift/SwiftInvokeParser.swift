//
//  SwiftInvokeParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/5.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 解析swift方法的调用
class SwiftInvokeParser: BacktrackParser {
    
    func parse() -> [ObjcMessageNode] {
        
        return invokes
    }
    
    // MARK: - Private
    
    fileprivate var invokes: [ObjcMessageNode] = []
}

// MARK: - 规则解析

fileprivate extension SwiftInvokeParser {
    
}
