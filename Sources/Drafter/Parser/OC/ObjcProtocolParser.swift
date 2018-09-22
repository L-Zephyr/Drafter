//
// Created by LZephyr on 2018/9/19.
//

import Foundation
import SwiftyParse

class ObjcProtocolParser: ConcreteParserType {
    var parser: TokenParser<[ProtocolNode]> {
        return self.protocol.continuous
    }
}

extension ObjcProtocolParser {
    /*
    解析一个oc协议
    protocol = '@protocol' NAME super_list body '@end'
    */
    var `protocol`: TokenParser<ProtocolNode> {
        return curry(ProtocolNode.init)
            <^> token(.ocProtocol) *> token(.name) => stringify
            <*> superList
            <*> body
    }

    /*
    解析协议的继承列表
    super_list = ('<' super_list '>')?
    */
    var superList: TokenParser<[String]?> {
        let lAngle = token(.leftAngle)
        let rAngle = token(.rightAngle)
        let comma = token(.comma)

        return curry({ tokens in tokens?.map { $0.text }})
            <^> token(.name).sepBy1(comma).between(lAngle, rAngle).try
    }

    /*
    用ObjcMethodParser解析协议中定义的方法
    */
    var body: TokenParser<[MethodNode]> {
        return curry({ ObjcMethodParser().declsParser.run($0) ?? [] })
            <^> anyTokens(until: token(.end))
    }
}