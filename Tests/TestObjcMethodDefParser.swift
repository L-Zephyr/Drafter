//
//  TestObjcMethodParser.swift
//  Tests
//
//  Created by LZephyr on 2017/9/27.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

class TestObjcMethodParser: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func parse(_ code: String) -> [MethodNode] {
        let lexer = SourceLexer(input: code)
        let parser = ObjcMethodParser(lexer: lexer)
        return parser.parse()
    }

    func testDeclNoParam() {
        let methods = parse("+ (_nonable NSString *)add;")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].isStatic == true)
        XCTAssert(methods[0].returnType == "_nonable NSString *")
        XCTAssert(methods[0].params[0].outterName == "add")
    }
    
    func testDeclWithParams() {
        let methods = parse("- (_nonable NSString *)add:(int)a andB:(long long)b;")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].isStatic == false)
        XCTAssert(methods[0].returnType == "_nonable NSString *")
        XCTAssert(methods[0].params.count == 2)
        
        XCTAssert(methods[0].params[0].innerName == "a")
        XCTAssert(methods[0].params[0].outterName == "add")
        XCTAssert(methods[0].params[0].type == "int")
        
        XCTAssert(methods[0].params[1].innerName == "b")
        XCTAssert(methods[0].params[1].outterName == "andB")
        XCTAssert(methods[0].params[1].type == "long long")
    }
    
    func testComplexParams() {
        let methods = parse("- (_nonable NSString *)add:(int *(^)(int))a andB:(long long)b;")
        
        XCTAssert(methods[0].params.count == 2)
        XCTAssert(methods[0].params[0].type == "int * ( ^ ) ( int )")
        XCTAssert(methods[0].params[0].outterName == "add")
        XCTAssert(methods[0].params[0].innerName == "a")
    }
    
    func testDef() {
        let code = """
            - (_nonable NSString *)add:(int)a andB:(long long)b {
                {
                    [self add: 1 andB:3];
                }
                
                NSString *s = @"[self add];"
            }
        """
        let methods = parse(code)
        
    }
}
