//
//  Executor.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/2.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

class Executor {
    
    // MARK: - Public
    
    /// 执行Shell指令
    ///
    /// - Parameters:
    ///   - executable: 可执行文件的名称
    ///   - args:       参数
    /// - Returns:      执行结果输出
    @discardableResult
    static func execute(_ executable: String, _ args: String...) -> String {
        
        // 查找可执行文件的
        func pathForExecutable(executable: String) -> String {
            guard !executable.characters.contains("/") else {
                return executable
            }
            let path = Executor.execute("/usr/bin/which", executable)
            return path.isEmpty ? executable : path
        }
        
        let process = Process()
        process.launchPath = pathForExecutable(executable: executable)
        process.arguments = args
        
        let command = Command(process: process)
        command.launch()
        
        // 如果结果只有一行, 去掉最后的回车
        var output = command.stdout
        let firstnewline = output.characters.index(of: "\n")
        if firstnewline == nil || output.characters.index(after: firstnewline!) == output.endIndex {
            output = output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return output
    }
}

fileprivate class Command {
    
    private let outputHandle: FileHandle
    private let process: Process
    
    init(process: Process) {
        self.process = process
        
        let pipe = Pipe()
        self.process.standardOutput = pipe
        outputHandle = pipe.fileHandleForReading
    }
    
    func launch() {
        process.launch()
        process.waitUntilExit()
    }
    
    lazy var stdout: String = {
        let data = outputHandle.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }()
}
