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

    func testMessageSend() {
        let text = "[self add: 2 andB: 3];"
        let lexer = Lexer(input: text)
        let parser = ObjcMessageSendParser(lexer: lexer)
        
        let calls = parser.parse()
    }

}
