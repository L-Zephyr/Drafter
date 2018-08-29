//
//  FileParser.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation
import PathKit

/*
 FileParser并没有继承自ConcreteParserType，它整合了底层所有ConcreteParser并对所有类型的源文件提供一致的接口（Facade模式），
 封装了将一个源码文件解析成FileNode的过程，并缓存结果
 */
class FileParser {
    
    // MARK: - Public
    
    /// 接受一个文件路径来初始化
    ///
    /// - Parameter path: 源码文件的路径
    init(_ path: Path) {
        self.sourcePath = path
    }
    
    /// 执行解析并获得结果，该方法会优先使用缓存
    ///
    /// - Returns: 解析结果
    func run(_ usingCache: Bool = true) -> FileNode? {
        // Read File
        var content: String
        do {
            content = try sourcePath.read()
            sourceMD5 = content.md5
        } catch {
            print("Fail To Read File: \(error)")
            return nil
        }
        
        if usingCache,
            sourcePath.cachePath().exists,
            let data: Data = try? sourcePath.cachePath().read(),
            let cache = try? JSONDecoder().decode(FileNode.self, from: data) { // 有缓存
            
            if cache.drafterVersion == DrafterVersion && cache.md5 == sourceMD5 {
                return cache
            } else { // 缓存失效
                return parseAndCache()
            }
        } else { // 无缓存
            return parseAndCache()
        }
    }
    
    // MARK: - Private
    
    /// 缓存未命中，执行解析并缓存结果
    fileprivate func parseAndCache() -> FileNode {
        // 1. parse
        var result: FileNode
        if sourcePath.isSwift {
            let tokens = SourceLexer(file: sourcePath.string).allTokens
            let types = SwiftTypeParser().parser.run(tokens) ?? []
            
            result = FileNode(md5: sourceMD5,
                              drafterVersion: DrafterVersion,
                              path: sourcePath.absolute().string,
                              type: sourcePath.fileType,
                              swiftTypes: types,
                              objcTypes: [])
        } else {
            let tokens = SourceLexer(file: sourcePath.string).allTokens
            let types = ObjcTypeParser().parser.run(tokens) ?? []
            
            result = FileNode(md5: sourceMD5,
                              drafterVersion: DrafterVersion,
                              path: sourcePath.absolute().string,
                              type: sourcePath.fileType,
                              swiftTypes: [],
                              objcTypes: types)
        }
        
        // 2. cache
        if let data = try? JSONEncoder().encode(result) {
            try? sourcePath.cachePath().write(data)
        }
        
        return result
    }
    
    fileprivate let sourcePath: Path // 源代码文件路径
    fileprivate var sourceMD5: String = ""
}
