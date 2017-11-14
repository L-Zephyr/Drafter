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
    
    func run(_ input: String) -> [MethodInvokeNode] {
        let tokens = SourceLexer(input: input).allTokens
        guard let result = ObjcMessageParser().parser.run(tokens) else {
            XCTAssert(false)
            return []
        }
        return result
    }
    
    // MARK: - 单步测试
    
    func testParam() {
        let input = """
        ^(int) {
            [self method];
            [self method2];
        }
        """
        let invokes = run(input)
        
        XCTAssert(invokes.count == 2)
    }
    
    // MARK: -
    
    func testNoParam() {
        let invokes = run("[[self method1] method2]")
        
        XCTAssert(invokes.count == 1)
        //
    }
    
    func testWithParams() {
        let invokes = run("[[self method] add: 1 and: 2]")
        
        XCTAssert(invokes.count == 1)
    }
    
    func testWithEquation() {
        let invokes = run("[self add: a + b + c and: 2]")
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].params.count == 2)
    }
    
    func testMethodParam() {
        let invokes = run("[self add: [self method] and: 2]")
        
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
        let invokes = run("[self add: [self method] and: 2]")
        
        XCTAssert(invokes.count == 2)
    }
}
