//
//  OCMsgSendTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/8.
//

import XCTest

class OCMsgSendTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - 单步测试
    
    func testParam() {
        let input = """
        ^(int) {
            [self method];
            [self method2];
        }
        """
        let tokens = SourceLexer(input: input).allTokens
        guard let invokes = ObjcMessageParser().param.run(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(invokes.count == 2)
    }
    
    // MARK: -
    
    func testNoParam() {
        let tokens = SourceLexer(input: "[[self method1] method2]").allTokens
        let invokes = ObjcMessageParser().parse(tokens)
        
        XCTAssert(invokes.count == 1)
        //
    }
    
    func testWithParams() {
        let tokens = SourceLexer(input: "[[self method] add: 1 and: 2]").allTokens
        let invokes = ObjcMessageParser().parse(tokens)
        
        XCTAssert(invokes.count == 1)
    }
    
    func testWithEquation() {
        let tokens = SourceLexer(input: "[self add: a + b + c and: 2]").allTokens
        let invokes = ObjcMessageParser().parse(tokens)
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].params.count == 2)
    }
    
    func testMethodParam() {
        let tokens = SourceLexer(input: "[self add: [self method] and: 2]").allTokens
        let invokes = ObjcMessageParser().parse(tokens)
        
        XCTAssert(invokes.count == 1)
//        XCTAssert(invokes[0].params.count == 2)
    }
    
    func testMethodBlock() {
        let input = """
        [self add: ^(int) {
            [self method];
        } and: 2];
        [self method2];
        """
        let tokens = SourceLexer(input: input).allTokens
        let invokes = ObjcMessageParser().parse(tokens)
        
        XCTAssert(invokes.count == 2)
    }
}
