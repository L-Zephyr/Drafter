//
//  Array+Extension.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation

extension Array {
    
    /// 字符数组连接操作
    func join(stringify: (Iterator.Element) -> String, separator: String) -> String {
        var result = ""
        
        for index in startIndex..<endIndex {
            result.append(contentsOf: stringify(self[index]))
            
            if index == self.index(before: endIndex) {
                continue
            }
            result.append(contentsOf: separator)
        }
        
        return result
    }
    
    /// 将Array转换成字典
    ///
    /// - Parameter selectKey: 将数组中的元素转成成Key，返回nil则跳过这个元素
    /// - Returns: 字典
    func toDictionary(_ selectKey: (Element) -> String?) -> [String: Element] {
        var dic = [String: Element]()
        for item in self {
            if let key = selectKey(item) {
                dic[key] = item
            }
        }
        
        return dic
    }
}

extension Array where Element: Hashable {
    func genericContain<E: Hashable>(_ ele: E) -> Bool {
        for item in self {
            if item.hashValue == ele.hashValue {
                return true
            }
        }
        return false
    }
}
