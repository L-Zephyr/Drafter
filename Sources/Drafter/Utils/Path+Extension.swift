//
//  Path+Extension.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/16.
//

import Foundation
import PathKit

extension Path {
    /// 获取该源码文件对应的缓存位置
    func cachePath() -> Path {
        let cacheDir = Path(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]) + "Drafter"
        if !cacheDir.exists {
            try? FileManager.default.createDirectory(at: cacheDir.url, withIntermediateDirectories: true, attributes: nil)
        }
        
        let hash = self.absolute().string.hashValue
        return cacheDir + "\(hash).srf"
    }
    
    /// 获取文件夹下的所有文件
    ///
    /// - Returns: 返回所有文件的集合，如果本身是一个文件则仅返回自身
    var files: [Path] {
        if self.isFile {
            return [self]
        } else {
            return Array(self)
        }
    }
    
    /// 获取绝对路径的散列值
    var pathHash: String {
        return self.absolute().string.md5
    }
    
//    /// 获取文件内容的散列值
//    var contentHash: String {
//
//    }
}
