//
//  main.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

enum DraftMode: String {
    case callGraph = "call"       // 调用图
    case inheritGraph = "inherit" // 类结构图
    case both = "both"
}

// 命令行参数解析
let filePath = StringOption("f", "file", true, "The file or directory to be parsed, supported: .h and .m")
let mode = EnumOption<DraftMode>(shortFlag: "m", longFlag: "mode", required: false, helpMessage: "The parsing mode, if you choose 'call', it will generate call graph. If you choose 'inherit' it will generate class inheritance graph. Default to 'call'")
let search = StringOption("s", "search", false, "Specify a keyword, the generate graph only contains thats nodes you are interested in")

let cli = CommandLine()
cli.addOptions(filePath, mode, search)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

// 指定文件
guard let path = filePath.value else {
    exit(EX_USAGE)
}

let drafter = Drafter()
drafter.keyword = search.value
drafter.mode = mode.value ?? .callGraph
drafter.path = path
drafter.craft()
