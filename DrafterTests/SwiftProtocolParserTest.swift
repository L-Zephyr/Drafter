//
//  SwiftProtocolParserTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/9.
//

import XCTest

class SwiftProtocolParserTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProtocol() {
        let tokens = SourceLexer(input: "protocol MyProtocol: Protocol1, Protocol2", isSwift: true).allTokens
        guard let protos = SwiftProtocolParser().parser.run(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(protos.count == 1)
        XCTAssert(protos[0].name == "MyProtocol")
        XCTAssert(protos[0].supers == ["Protocol1", "Protocol2"])
    }
    
}
