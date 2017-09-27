//
//  main.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

let filePath = StringOption("f", "file", true, "The file or directory to be parsed, supported: .h and .m")

let cli = CommandLine()
cli.addOptions(filePath)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

// 解析指定文件
guard let path = filePath.value else {
    exit(EX_USAGE)
}

let drafter = Drafter()
drafter.path = path

drafter.makeMap()
