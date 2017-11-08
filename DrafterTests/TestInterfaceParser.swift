//
//  Tests.swift
//  Tests
//
//  Created by LZephyr on 2017/9/25.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class TestInterfaceParser: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func parse(_ code: String) -> [ClassNode] {
        let tokens = SourceLexer(input: code).allTokens
        let parser = InterfaceParser()
        return parser.parse(tokens)
    }
    
    func testInterface() {
        let result = parse("@interface MyClass: NSObject<TestDelegate1>")
        
        XCTAssert(result.count == 1)
        XCTAssert(result[0].className == "MyClass")
        XCTAssert(result[0].superCls != nil)
        XCTAssert(result[0].superCls!.className == "NSObject")
        XCTAssert(result[0].protocols.count == 1)
        XCTAssert(result[0].protocols[0] == "TestDelegate1", "Unexpected: \(result[0].protocols[0])")
    }
    
    func testUnderlineInterface() {
        let result = parse("@interface _MyCla1ss: NSObject<TestDelegate1>")
        
        XCTAssert(result.count == 1)
        XCTAssert(result[0].className == "_MyCla1ss")
        XCTAssert(result[0].superCls != nil)
        XCTAssert(result[0].superCls!.className == "NSObject")
        XCTAssert(result[0].protocols.count == 1)
        XCTAssert(result[0].protocols[0] == "TestDelegate1", "Unexpected: \(result[0].protocols[0])")
    }
    
    func testExtension() {
        let result = parse("@interface _MyClass() < TestDelegate1>")
        
        XCTAssert(result.count == 1)
        XCTAssert(result[0].className == "_MyClass")
        XCTAssert(result[0].superCls == nil)
        XCTAssert(result[0].protocols.count == 1)
        XCTAssert(result[0].protocols[0] == "TestDelegate1", "Unexpected: \(result[0].protocols[0])")
    }
    
    func testCategory() {
        let result = parse("@interface _MyClass(category) < TestDelegate1>")
        
        XCTAssert(result.count == 1)
        XCTAssert(result[0].className == "_MyClass")
        XCTAssert(result[0].superCls == nil)
        XCTAssert(result[0].protocols.count == 1)
        XCTAssert(result[0].protocols[0] == "TestDelegate1", "Unexpected: \(result[0].protocols[0])")
    }
    
    func testMerge() {
        let input =
        """
        @interface _MyClass: NSObject <TestDelegate1, TestDelegate2>
        @interface _MyClass() <TestDelegate1>
        @interface _MyClass(category) <TestDelegate3>
        """
        let result = parse(input)
        
        XCTAssert(result.count == 1)
        XCTAssert(result[0].className == "_MyClass")
        XCTAssert(result[0].superCls != nil)
        XCTAssert(result[0].superCls!.className == "NSObject")
        XCTAssert(result[0].protocols.count == 3)
        XCTAssert(result[0].protocols[0] == "TestDelegate1")
        XCTAssert(result[0].protocols[1] == "TestDelegate2")
        XCTAssert(result[0].protocols[2] == "TestDelegate3")
    }
}
