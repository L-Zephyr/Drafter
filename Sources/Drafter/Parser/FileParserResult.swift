//
//  FileParserResult.swift
//  Drafter
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation

struct FileParserResult {
    let md5: String
    let drafterVersion: String
    let path: String
    let isSwift: Bool
    
    // Swift文件用这个
    let swiftClasses: [ClassNode]
    
    // OC文件用这个
    let interfaces: [InterfaceNode]
    let implementations: [ImplementationNode]
}

// MARK: - 结果合并

extension Array where Element == FileParserResult {
    
}
