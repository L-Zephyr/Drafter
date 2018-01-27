//
//  ParserRunner.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2018/1/27.
//

import Foundation

fileprivate let maxConcurrent: Int = 4 // 多线程解析最大并发数

class ParserRunner {
    
    static let runner = ParserRunner()
    
    fileprivate let semaphore = DispatchSemaphore(value: maxConcurrent)
    
    // MARK: - 0.3.0接口
    
    func parse(files: [String]) -> [ClassNode] {
        return []
    }
    
    // MARK: - 0.2.0接口
    
    /// 解析代码中的方法调用
    ///
    /// - Parameter files: 输入的文件路径
    /// - Returns: 字典，key为文件，value为方法数组
    func parseMethods(files: [String]) -> [String: [MethodNode]] {
        var results = [String: [MethodNode]]()
        
        func runParse(_ file: String) -> [MethodNode] {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            var nodes = [MethodNode]()
            
            if file.isSwift {
                let result = SwiftMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: result)
            } else {
                let result = ObjcMethodParser().parser.run(tokens) ?? []
                nodes.append(contentsOf: result)
            }
            return nodes
        }
        
        // 1. 解析方法调用
        let sources = files.filter({ !$0.hasSuffix(".h") })
        for file in sources {
            semaphore.wait()
            DispatchQueue.global().async {
                results[file] = runParse(file)
                self.semaphore.signal()
            }
        }
        
        waitUntilFinished()
        
        return results
    }
    
    func parseInerit(files: [String]) -> ([ClassNode], [ProtocolNode]) {
        var classes = [ClassNode]()
        var protocols = [ProtocolNode]()
        let writeQueue = DispatchQueue(label: "WriteClass")
        
        // 解析OC类型
        func parseObjcClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let result = InterfaceParser().parser.toClassNode.run(tokens) ?? []
            writeQueue.sync {
                classes.merge(result)
            }
        }
        
        // 解析swift类型
        func parseSwiftClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let (protos, cls) = SwiftInheritParser().parser.run(tokens) ?? ([], [])
            writeQueue.sync {
                protocols.append(contentsOf: protos)
                classes.merge(cls)
            }
        }
        
        // 1. 解析OC文件
        for file in files.filter({ !$0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseObjcClass(file)
                self.semaphore.signal()
            }
        }
        
        // 2. 解析swift文件
        for file in files.filter({ $0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseSwiftClass(file)
                self.semaphore.signal()
            }
        }
        
        // 3. 等待所有线程执行结束
        waitUntilFinished()
        
        return (classes, protocols)
    }
    
    /// 等待直到所有任务完成
    private func waitUntilFinished() {
        for _ in 0..<maxConcurrent {
            semaphore.wait()
        }
        for _ in 0..<maxConcurrent {
            semaphore.signal()
        }
    }
}
