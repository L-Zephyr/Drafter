//
//  SwiftClassParserTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/10.
//

import XCTest

class SwiftClassParserTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClass() {
        let tokens = SourceLexer(input: "class MyClass: Super, Proto1", isSwift: true).allTokens
        guard let cls = SwiftClassParser().parser.run(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(cls.count == 1)
        XCTAssert(cls[0].className == "MyClass")
        XCTAssert(cls[0].superCls! == "Super")
        XCTAssert(cls[0].protocols == ["Proto1"])
    }
    
    func testClassNoInherit() {
        let tokens = SourceLexer(input: "class MyClass", isSwift: true).allTokens
        guard let cls = SwiftClassParser().parser.run(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(cls.count == 1)
        XCTAssert(cls[0].className == "MyClass")
        XCTAssert(cls[0].superCls == nil)
        XCTAssert(cls[0].protocols.count == 0)
    }
    
    func testClassWithGeneric() {
        let tokens = SourceLexer(input: "class MyClass<T, A>: Super", isSwift: true).allTokens
        guard let cls = SwiftClassParser().parser.run(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(cls.count == 1)
        XCTAssert(cls[0].className == "MyClass")
        XCTAssert(cls[0].superCls! == "Super")
        XCTAssert(cls[0].protocols.count == 0)
    }
    
    func testClassWithExtension() {
        let input = """
        class MyClass<T, A>: Super {}
        extension MyClass: Proto1 {}
        """
        let tokens = SourceLexer(input: input, isSwift: true).allTokens
        guard let cls = SwiftClassParser().parser.run(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(cls.count == 1)
        XCTAssert(cls[0].className == "MyClass")
        XCTAssert(cls[0].superCls! == "Super")
        XCTAssert(cls[0].protocols == ["Proto1"])
    }
}
