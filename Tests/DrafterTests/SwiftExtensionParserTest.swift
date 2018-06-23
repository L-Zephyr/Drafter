//
//  SwiftExtensionParserTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/6/9.
//

import XCTest

class SwiftExtensionParserTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func run(_ input: String) -> [ExtensionNode] {
        let tokens = SourceLexer(input: input, isSwift: true).allTokens
        guard let exts = SwiftExtensionParser().parser.run(tokens) else {
            XCTAssert(false)
            return []
        }
        return exts
    }
    
    func testEmpty() {
        let input = "extension NSObject {}"
        let exts = run(input)
        
        XCTAssert(exts.count == 1)
        XCTAssert(exts[0].name == "NSObject")
        XCTAssert(exts[0].protocols == [])
        XCTAssert(exts[0].methods == [])
    }
    
    func testProtocols() {
        let input = "extension NSObject: Proto1 {}"
        let exts = run(input)
        
        XCTAssert(exts.count == 1)
        XCTAssert(exts[0].name == "NSObject")
        XCTAssert(exts[0].protocols == ["Proto1"])
        XCTAssert(exts[0].methods == [])
    }
    
    func testAll() {
        let input = """
        extension NSObject: Proto1, Proto2 {
            func method1() {}
            func method2() {}
        }
        """
        let exts = run(input)
        
        XCTAssert(exts.count == 1)
        XCTAssert(exts[0].name == "NSObject")
        XCTAssert(exts[0].protocols == ["Proto1", "Proto2"])
        XCTAssert(exts[0].methods.count == 2)
    }
}
