//
//  InterfaceTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/5.
//

import XCTest

extension Array where Element: Equatable {
    static func == (_ lhs: Array<Element>, _ rhs: Array<Element>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for index in 0..<lhs.count {
            if lhs[index] != rhs[index] {
                return false
            }
        }
        return true
    }
}

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
        let tokens = SourceLexer(input: "@interface MyClass: NSObject < Delegate1, Delegate2>").allTokens
        let parser = InterfaceGenParser()
        
        let nodes = parser.parse(tokens)
        
        XCTAssert(nodes.count == 1)
        XCTAssert(nodes[0].className == "MyClass")
        XCTAssert(nodes[0].protocols == ["Delegate1", "Delegate2"])
    }
}
