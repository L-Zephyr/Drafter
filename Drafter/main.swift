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
let filePath = StringOption("f", "file", true, "The file or directory to be parsed, supported: .h and .m. Multiple arguments are separated by commas.")
let mode = EnumOption<DraftMode>(shortFlag: "m", longFlag: "mode", required: false, helpMessage: "The parsing mode, if you choose 'call', it will generate call graph. If you choose 'inherit' it will generate class inheritance graph. Default to 'call'")
let search = StringOption("s", "search", false, "Specify a keyword, the generate graph only contains thats nodes you are interested in. Multiple arguments are separated by commas")
let selfOnly = BoolOption("self", "self-method-only", false, "Only contains the methods defined in the user code")

let cli = CommandLine()
cli.addOptions(filePath, mode, search, selfOnly)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

// 指定文件
guard let paths = filePath.value else {
    exit(EX_USAGE)
}

let drafter = Drafter()
drafter.keywords = search.value?.split(by: ",").map { $0.lowercased() } ?? []
drafter.mode = mode.value ?? .callGraph
drafter.selfOnly = selfOnly.value
drafter.paths = paths
drafter.craft()
