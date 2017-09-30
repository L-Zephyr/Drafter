//
//  TestMessageSend.swift
//  Tests
//
//  Created by LZephyr on 2017/9/28.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class TestMessageSend: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func parse(_ code: String) -> [ObjcMessageNode] {
        let lexer = SourceLexer(input: code)
        let parser = ObjcMessageSendParser(lexer: lexer)
        return parser.parse()
    }

    func testMessageSend1() {
        let calls = parse("[self add: 2 andB: 3];")
    }
    
    func testMessageSend2() {
        let calls = parse("[self add: andB: ];")
    }
    
    func testMessageSend3() {
        let calls = parse("[self add: ^{ int a = 1;} andB: ];")
    }
}
