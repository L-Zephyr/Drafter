//
//  main.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation
import PathKit

enum DraftMode: String {
    case invokeGraph = "invoke"       // 调用图
    case inheritGraph = "inherit" // 类结构图
    case both = "both"
}

// 输出类型
enum DraftOutputType: String {
    case html = "html"
    case png = "png"
}

// 命令行参数解析
let filePath = StringOption("f", "file", true, "The file or directory to be parsed, supported: .h and .m. Multiple arguments are separated by commas.")

let output = EnumOption<DraftOutputType>(shortFlag: "t", longFlag: "type", required: false, helpMessage: "The output type. Choose 'html' to generate a html page, choose 'png' to generate a picture. Defaults to 'html'")

let mode = EnumOption<DraftMode>(shortFlag: "m", longFlag: "mode", required: false, helpMessage: "The parsing mode. Assign 'invoke' will generate call graph, assign 'inherit' will generate class inheritance graph, or 'both' to do both call and inheritance analysis. Defaults to 'invoke'")

let search = StringOption("s", "search", false, "Specify a keyword, the generate graph only contains thats nodes you are interested in. Multiple arguments are separated by commas")

let selfOnly = BoolOption("self", "self-method-only", false, "Only contains the methods defined in the user code")

let cli = CommandLine()
cli.addOptions(filePath, output, mode, search, selfOnly)

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
drafter.outputType = output.value ?? .html
drafter.mode = mode.value ?? .invokeGraph
drafter.selfOnly = selfOnly.value
drafter.paths = paths
drafter.craft()
