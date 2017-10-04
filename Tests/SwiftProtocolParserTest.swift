//
//  SwiftProtocolParserTest.swift
//  Tests
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class SwiftProtocolParserTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func parse(_ code: String) -> [ProtocolNode] {
        let lexer = SourceLexer(input: code, isSwift: true)
        let parser = SwiftProtocolParser(lexer: lexer)
        return parser.parse()
    }

    func testProtocol() {
        let proto = parse("protocol Proto: Hashable, _MyProto {}")
        
        XCTAssert(proto.count == 1)
        XCTAssert(proto[0].name == "Proto")
        XCTAssert(proto[0].supers.count == 2)
        XCTAssert(proto[0].supers[0] == "Hashable")
        XCTAssert(proto[0].supers[1] == "_MyProto")
    }
}
