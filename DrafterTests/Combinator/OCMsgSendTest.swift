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
    
//    func testReceiver() {
//        let tokens = SourceLexer(input: "[self method]").allTokens
//
//        guard let rec = ObjcMessageGenParser().receiver.run(tokens) else {
//            XCTAssert(false)
//            return
//        }
//
//    }
    
    // MARK: -
    
    func testNoParam() {
        let tokens = SourceLexer(input: "[[self method1] method2]").allTokens
        let invokes = ObjcMessageGenParser().parse(tokens)
        
        XCTAssert(invokes.count == 1)
        //
    }
    
    func testWithParams() {
        let tokens = SourceLexer(input: "[[self method] add: 1 and: 2]").allTokens
        let invokes = ObjcMessageGenParser().parse(tokens)
        
        XCTAssert(invokes.count == 1)
    }
    
    func testWithEquation() {
        let tokens = SourceLexer(input: "[self add: a + b and: 2]").allTokens
        let invokes = ObjcMessageGenParser().parse(tokens)
        
        XCTAssert(invokes.count == 1)
    }
    
    func testMethodParam() {
        let tokens = SourceLexer(input: "[add: [self method] and: 2]").allTokens
        let invokes = ObjcMessageGenParser().parse(tokens)
        
        XCTAssert(invokes.count == 2)
    }
}
