//
//  TestSwiftMethodParser.swift
//  Tests
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class TestSwiftMethodParser: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func parse(_ code: String) -> [MethodNode] {
        let lexer = SourceLexer(input: code, isSwift: true)
        let parser = SwiftMethodParser(lexer: lexer)
        return parser.parse()
    }
    
    func testMethod() {
        let methods = parse("class func method(_ param: Int, param2: @autoclosure ()->(), param3 param3: inout (Int, Int) -> Void) -> () -> Int { method2() }")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].methodName == "method")
        XCTAssert(methods[0].params.count == 3)
        XCTAssert(methods[0].returnType == "( ) -> Int")
        XCTAssert(methods[0].invokes[0].methodName == "method2")
    }
}
