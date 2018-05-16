//
//  ImplementationTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/1/28.
//

import XCTest

class ImplementationTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testImp() {
        let code = """
        @implementation MyClass(Extension)
        - (void)method {
            [self method2];
        }
        @end
        """
        
        let tokens = SourceLexer(input: code).allTokens
        guard let result = ImplementationParser().parser.run(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.count == 1)
        XCTAssert(result[0].className == "MyClass")
        XCTAssert(result[0].methods.count == 1)
    }
}
