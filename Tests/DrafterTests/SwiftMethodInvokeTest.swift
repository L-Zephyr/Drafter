//
//  SwiftMethodInvokeTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/13.
//

import XCTest

class SwiftMethodInvokeTest: XCTestCase {
    
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
        guard let result = SwiftInvokeParser().parser.run(tokens) else {
            XCTAssert(false)
            return []
        }
        return result
    }
    
    func testNoParam() {
        let invokes = run("method()")
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].methodName == "method")
        XCTAssert(invokes[0].params.count == 0)
    }
    
    func testSeqMethod() {
        let invokes = run("self.method().method1().method2()")
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].description == "method().method1().method2()")
    }
    
    func testSingleParam() {
        let invokes = run("method(name)")
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].methodName == "method")
        XCTAssert(invokes[0].params.count == 1)
    }
    
    func testParams() {
        let invokes = run("add(a: a + b, and: 5)")
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].methodName == "add")
        XCTAssert(invokes[0].params.count == 2)
    }
    
    func testMethodParams() {
        let invokes = run("add(a: method(), and: 5)")
        
        XCTAssert(invokes.count == 2)
        XCTAssert(invokes[0].params.count == 2)
        XCTAssert(invokes[1].params.count == 0)
    }
    
    func testMultiMethodParams() {
        let invokes = run("add(a: method() + method2(), and: 5)")
        
        XCTAssert(invokes.count == 3)
        XCTAssert(invokes[0].params.count == 2)
        XCTAssert(invokes[1].params.count == 0)
        XCTAssert(invokes[2].params.count == 0)
    }
    
    func testInvokeSeq() {
        let invokes = run("self.value.method().add(a: a + b, and: 5)")
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].params.count == 2)
    }
    
    func testComplexInvoke() {
        let input = """
        method(add: 3, completion: {
            self.add(a: 2, and: 5)
            self.doSomthing()
        })
        """
        let invokes = run(input)
        
        XCTAssert(invokes.count == 3)
    }
}
