//
//  SwiftClassParserTest.swift
//  Tests
//
//  Created by LZephyr on 2017/10/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class TestSwiftClassParser: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func parse(_ code: String) -> [ClassNode] {
        let lexer = SourceLexer(input: code, isSwift: true)
        let parser = SwiftClassParser(lexer: lexer)
        return parser.parse()
    }

    func testParseClass() {
        let cls = parse("public class MyClass: NSObject, Delegate {}")
        
        XCTAssert(cls.count == 1)
        XCTAssert(cls[0].className == "MyClass")
        XCTAssert(cls[0].superCls != nil && cls[0].superCls!.className == "NSObject")
        XCTAssert(cls[0].protocols.count == 1)
        XCTAssert(cls[0].protocols[0] == "Delegate")
    }

    func testWithExtension() {
        let code = """
        public class MyClass: NSObject, Delegate {}
        extension MyClass: Delegate2, Delegate { }

        """
        let cls = parse(code)
        
        XCTAssert(cls.count == 1)
        XCTAssert(cls[0].className == "MyClass")
        XCTAssert(cls[0].superCls != nil && cls[0].superCls!.className == "NSObject")
        XCTAssert(cls[0].protocols.count == 2)
        XCTAssert(cls[0].protocols[0] == "Delegate")
        XCTAssert(cls[0].protocols[1] == "Delegate2")
    }
}
