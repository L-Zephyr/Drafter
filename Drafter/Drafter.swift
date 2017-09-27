//
//  Mapper.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/26.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

class Drafter {
    
    // MARK: - Public
    
    /// 待解析的文件或文件夹, 目前只支持.h和.m文件
    var path: String = "" {
        didSet {
            var isDir: ObjCBool = ObjCBool.init(false)
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
                // 如果是文件夹则获取所有.h和.m文件
                if isDir.boolValue, let enumerator = FileManager.default.enumerator(atPath: path) {
                    while let file = enumerator.nextObject() as? String {
                        if file.hasSuffix(".h") || file.hasSuffix(".m") {
                            files.append("\(path)/\(file)")
                        }
                    }
                } else {
                    files = [path]
                }
            } else {
                print("File: \(path) not exist")
            }
        }
    }
    
    /// 生成调用图
    func makeMap() {
        
    }
    
    // MARK: - Private
    
    fileprivate var files: [String] = []
}
