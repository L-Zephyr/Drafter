//
//  FileParser.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation
import PathKit

/*
 FileParser并没有继承自ParserType，它整合了底层所有Parser并对所有类型的源文件提供一致的接口（外观模式），
 封装了将一个源码文件解析成FileParserResult的过程，并缓存结果
 */
class FileParser {
    
    /// 接受一个文件路径来初始化
    ///
    /// - Parameter path: 源码文件的路径
    init(_ path: Path) {
        self.path = path
    }
    
    /// 执行解析并获得结果，该方法会优先使用缓存
    ///
    /// - Returns: 解析结果
    func run() -> FileParserResult? {
        // Read File
        var content: String
        do {
            content = try path.read()
        } catch {
            print("Fail To Read File: \(error)")
            return nil
        }
        
        if path.cachePath().exists { // 有缓存
            
        } else { // 无缓存
            
        }
    }
    
    fileprivate let path: Path // 文件路径
}

extension FileParser {
    
}
