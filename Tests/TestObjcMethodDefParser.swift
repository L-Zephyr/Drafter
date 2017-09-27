//
//  TestObjcMethodDefParser.swift
//  Tests
//
//  Created by LZephyr on 2017/9/27.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class TestObjcMethodDefParser: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMethodDecl() {
        let text = "- (_nonable NSString *)add;"
        let lexer = Lexer(input: text)
        let parser = ObjcMethodDefParser(lexer: lexer)
        
        let methods = parser.parse()
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].isStatic == false)
        XCTAssert(methods[0].returnType == "_nonable NSString *")
    }

}
