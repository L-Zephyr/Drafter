//
//  InterfaceTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/5.
//

import XCTest

class InterfaceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClassWithSuper() {
        let tokens = SourceLexer(input: "@interface _MyClass: NSObject < Delegate1, Delegate2>").allTokens
        let parser = InterfaceGenParser()
        
        let nodes = parser.parse(tokens)
    }
}
