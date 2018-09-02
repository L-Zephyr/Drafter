//
//  ParserRunner.swift
//  drafterPackageDescription
//
//  Created by LZephyr on 2018/1/27.
//

import Foundation
import PathKit

fileprivate let maxConcurrent: Int = 4 // 多线程解析最大并发数

class ParserRunner {
    
    static let runner = ParserRunner()

    func parse(files: [Path], usingCache: Bool = true) -> [ClassNode] {
        let ocFiles = files.filter { $0.isObjc }
        let swiftFiles = files.filter { $0.isSwift }
        
        interfaces = []
        implementations = []
        classList = []
        
        var results: [FileNode] = []
        
        // 1. 解析OC文件
        for file in ocFiles {
            print("Parsing: \(file.lastComponent)")
            semaphore.wait()
            DispatchQueue.global().async {
                if let result = FileParser(file).run(usingCache) {
                    results.append(result)
                }
                self.semaphore.signal()
            }
        }
        
        // 2. 解析Swift文件
        for file in swiftFiles {
            print("Parsing: \(file.lastComponent)")
            semaphore.wait()
            DispatchQueue.global().async {
                if let result = FileParser(file).run(usingCache) {
                    results.append(result)
                }
                self.semaphore.signal()
            }
        }
        
        waitUntilFinished()

        return Preprocessor.shared.process(results)
    }

    fileprivate let semaphore = DispatchSemaphore(value: maxConcurrent)
    
    fileprivate var interfaces: [InterfaceNode] = []
    fileprivate var implementations: [ImplementationNode] = []
    fileprivate var classList: [ClassNode] = []
}

// MARK: - 0.2.0以前的接口, 不建议使用

extension ParserRunner {
    /// 解析代码中的方法调用
    ///
    /// - Parameter files: 输入的文件路径
    /// - Returns: 字典，key为文件，value为方法数组
    func parseMethods(files: [Path]) -> [String: [MethodNode]] {
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
        let sources = files.filter({ !$0.string.hasSuffix(".h") })
        for file in sources {
            semaphore.wait()
            DispatchQueue.global().async {
                results[file.string] = runParse(file.string)
                self.semaphore.signal()
            }
        }
        
        waitUntilFinished()
        
        return results
    }
    
    /// 解析代码中的类型
    ///
    /// - Parameter files: 文件
    /// - Returns: 返回一个元组，分别为所有的类型和协议数据
    func parseInerit(files: [Path]) -> ([ClassNode], [ProtocolNode]) {
        var classes = [ClassNode]()
        var protocols = [ProtocolNode]()
        let writeQueue = DispatchQueue(label: "WriteClass")
        
        // 解析OC类型
        func parseObjcClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let result = InterfaceParser().parser.run(tokens) ?? []
            writeQueue.sync {
                classes.append(contentsOf: result.map { ClassNode(interface: $0) })
            }
        }
        
        // 解析swift类型
        func parseSwiftClass(_ file: String) {
            print("Parsing \(file)...")
            let tokens = SourceLexer(file: file).allTokens
            let types = SwiftTypeParser().parser.run(tokens) ?? []
            writeQueue.sync {
                protocols.append(contentsOf: types.protocols)
                classes.append(contentsOf: types.classes)
            }
        }
        
        // 1. 解析OC文件
        for file in files.filter({ $0.isObjc }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseObjcClass(file.string)
                self.semaphore.signal()
            }
        }
        
        // 2. 解析swift文件
        for file in files.filter({ $0.isSwift }) {
            semaphore.wait()
            DispatchQueue.global().async {
                parseSwiftClass(file.string)
                self.semaphore.signal()
            }
        }
        
        // 3. 等待所有线程执行结束
        waitUntilFinished()
        
        return (DistinctPass().run(onClasses: classes), protocols)
    }
}

// MARK: - Private

extension ParserRunner {
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
