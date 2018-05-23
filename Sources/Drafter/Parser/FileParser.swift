//
//  FileParser.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation
import PathKit

/*
 FileParser并没有继承自ParserType，它整合了底层所有Parser并对所有类型的源文件提供一致的接口（Facade模式），
 封装了将一个源码文件解析成FileParserResult的过程，并缓存结果
 */
class FileParser {
    
    /// 接受一个文件路径来初始化
    ///
    /// - Parameter path: 源码文件的路径
    init(_ path: Path) {
        self.sourcePath = path
    }
    
    /// 执行解析并获得结果，该方法会优先使用缓存
    ///
    /// - Returns: 解析结果
    func run() -> FileParserResult? {
        // Read File
        var content: String
        do {
            content = try sourcePath.read()
            sourceMD5 = content.md5
        } catch {
            print("Fail To Read File: \(error)")
            return nil
        }
        
        if sourcePath.cachePath().exists, let data: Data = try? sourcePath.cachePath().read(), let cache = try? JSONDecoder().decode(FileParserResult.self, from: data) { // 有缓存
            if cache.drafterVersion == DrafterVersion && cache.md5 == sourceMD5 {
                print("缓存命中: \(sourcePath.lastComponent)")
                return cache
            } else { // 缓存失效
                return parseAndCache()
            }
        } else { // 无缓存
            return parseAndCache()
        }
    }
    
    /// 缓存未命中，执行解析并缓存结果
    fileprivate func parseAndCache() -> FileParserResult {
        print("缓存未命中: \(sourcePath.lastComponent)")
        // 1. parse
        var result: FileParserResult
        if sourcePath.isSwift {
            let tokens = SourceLexer(file: sourcePath.string).allTokens
            let (_, classes) = SwiftParser().parser.run(tokens) ?? ([],[]) // TODO
            
            result = FileParserResult(md5: sourceMD5,
                                      drafterVersion: DrafterVersion,
                                      path: sourcePath.absolute().string,
                                      isSwift: true,
                                      swiftClasses: classes,
                                      interfaces: [],
                                      implementations: [])
        } else {
            let tokens = SourceLexer(file: sourcePath.string).allTokens
            let interface = InterfaceParser().parser.run(tokens) ?? []
            let imp = ImplementationParser().parser.run(tokens) ?? []
            
            result = FileParserResult(md5: sourceMD5,
                                      drafterVersion: DrafterVersion,
                                      path: sourcePath.absolute().string,
                                      isSwift: false,
                                      swiftClasses: [],
                                      interfaces: interface,
                                      implementations: imp)
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
