//
// Created by LZephyr on 2018/9/22.
//

import Foundation

extension Array where Element == ClassNode {
    /// 查找指定类型
    func find(name: String) -> ClassNode? {
        if let index = self.index(where: { $0.className == name }) {
            return self[index]
        }
        return nil
    }
}

extension Array where Element == MethodNode {
    /// 根据方法的名字查找
    func find(methodName: String) -> MethodNode? {
        if let index = self.index(where: { $0.params[0].outterName == methodName }) {
            return self[index]
        }
        return nil
    }
}