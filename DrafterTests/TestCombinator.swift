//
//  TestCombinator.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/1.
//

import XCTest

class TestCombinator: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSeparator1() {
        let tokens: [Token] = [Token(type: .name, text: "name1"),
                               Token(type: .comma, text: ","),
                               Token(type: .name, text: "name2"),
                               Token(type: .comma, text: ",")]
        let comma = token(.comma)
        let parser = token(.name).separateBy(comma)
        XCTAssert(parser.parse(tokens) == nil)
    }
    
    func testSeparator2() {
        let tokens: [Token] = [Token(type: .name, text: "name1"),
                               Token(type: .comma, text: ","),
                               Token(type: .name, text: "name2")]
        let comma = token(.comma)
        let parser = token(.name).separateBy(comma)
        
        guard let (result, rest) = parser.parse(tokens) else {
            XCTAssert(false)
            return
        }
        XCTAssert(result.count == 2)
        XCTAssert(rest.count == 0)
    }

}
