//
//  DrafterParser.swift
//  Drafter
//
//  Created by LZephyr on 2018/1/24.
//

import Cocoa

// 0.3.0: 新增的一个通用Parser, 用来分析所有的代码文件
class DrafterParser: ParserType {
    
    var parser: Parser<[ClassNode]> {
        if isSwift {
            return swiftParser
        } else {
            return ocParser
        }
    }
    
    init(swift: Bool) {
        self.isSwift = swift
    }
    
    private var isSwift: Bool = false
}

extension DrafterParser {
    var ocParser: Parser<[ClassNode]> {
//        let inerface = InterfaceParser().parser
//        let imp = ImplementationParser().parser
        
        
        
        return pure([])
    }
    
    var swiftParser: Parser<[ClassNode]> {
        return pure([])
    }
}
