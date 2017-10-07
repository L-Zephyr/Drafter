//
//  TestSwiftInvokeParser.swift
//  Tests
//
//  Created by LZephyr on 2017/10/5.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class TestSwiftInvokeParser: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func parse(_ code: String) -> [MethodInvokeNode] {
        let lexer = SourceLexer(input: code, isSwift: true)
        let parser = SwiftInvokeParser(lexer: lexer)
        return parser.parse()
    }

    func testInvoke() {
        let code = """
            method(b: {
                method2()
            }, 3, result: {(Int) -> Int in
                method3()
                return 3
            })
        """
        let invokes = parse(code)
        
        XCTAssert(invokes.count == 3)
    }
    
    func testTailingClosure1() {
        let code = """
        method {
            
        }
        """
        let invokes = parse(code)
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].methodName == "method")
    }
    
    func testTailingClosure2() {
        let code = """
        method(num: 3) {
            
        }
        """
        let invokes = parse(code)
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].methodName == "method")
        XCTAssert(invokes[0].params.count == 2)
        XCTAssert(invokes[0].params[0] == "num:")
    }
    
    func testSequenceInvokes() {
        let code = """
        self.method(num: 3).method2("").method3()
        """
        let invokes = parse(code)
        
        XCTAssert(invokes.count == 1)
        XCTAssert(invokes[0].methodName == "method")
    }
}
