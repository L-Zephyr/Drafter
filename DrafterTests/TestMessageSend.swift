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
    
    func parse(_ code: String) -> [MethodInvokeNode] {
        let lexer = SourceLexer(input: code)
        let parser = ObjcMessageSendParser(lexer: lexer)
        return parser.parse()
    }

    func testMessageSend1() {
        let calls = parse("[self add: 2 andB: 3];")
        
        XCTAssert(calls.count == 1)
        XCTAssert(calls[0].params[0] == "add:")
        XCTAssert(calls[0].params[1] == "andB:")
    }
    
    func testMessageAsParam() {
        let calls = parse("[self add:[self message: 3] andB: 4];")
        
        XCTAssert(calls.count == 2)
    }
    
    func testMessageAsReceiver() {
        let calls = parse("[[obj fun1] add: 2];")
        
        XCTAssert(calls.count == 1)
        XCTAssert(calls[0].params[0] == "add:")
    }
    
    func testMessageWithBlock() {
        let calls = parse("[self add: ^{ [strongSelf method]} andB: ];")
        
        XCTAssert(calls.count == 2)
    }
}
