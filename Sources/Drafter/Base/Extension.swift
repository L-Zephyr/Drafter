//
//  Extension.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/6.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

extension Array {
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
}

extension String {
    func contains(_ keywords: [String]) -> Bool {
        if keywords.isEmpty {
            return true
        }
        
        for keyword in keywords {
            if self.contains(keyword) {
                return true
            }
        }
        return false
    }
    
    var isSwift: Bool {
        return hasSuffix(".swift")
    }
}
