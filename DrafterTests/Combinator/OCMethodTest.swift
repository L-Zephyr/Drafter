//
//  OCMethodTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/7.
//

import XCTest

class OCMethodTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMethodSelector() {
        let tokens = SourceLexer(input: "method").allTokens
        
        guard let params = ObjcMethodParser().methodSelector.run(tokens) else {
            XCTAssert(false)
            return
        }
        XCTAssert(params.count == 1)
    }
    
    // MARK: -
    
    func testMethodDecl() {
        let tokens = SourceLexer(input: "+ (_nonable NSString *)add:(int)a andB:(long long)b;").allTokens
        
        let methods = ObjcMethodParser().parse(tokens)
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].isStatic == true)
        XCTAssert(methods[0].params.count == 2)
    }
    
    func testMethodDeclNoParam() {
        let tokens = SourceLexer(input: "+ (_nonable NSString *)method;").allTokens
        
        let methods = ObjcMethodParser().parse(tokens)
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].isStatic == true)
        XCTAssert(methods[0].params.count == 1)
    }
    
    /// 测试多个方法
    func testMulitMethod() {
        let input = """
        + (_nonable NSString *)add:(int)a andB:(long long)b;
        - (void)method {
            a = b
        }
        """
        let tokens = SourceLexer(input: input).allTokens
        let methods = ObjcMethodParser().parse(tokens)
        
        guard methods.count == 2 else {
            XCTAssert(false)
            return
        }
        XCTAssert(methods[0].isStatic == true)
        XCTAssert(methods[0].params.count == 2)
        XCTAssert(methods[1].isStatic == false)
        XCTAssert(methods[1].params.count == 1)
        XCTAssert(methods[1].methodBody.count == 3)
    }
    
    func testMethodDef() {
        let tokens = SourceLexer(input: "+ (_nonable NSString *)add:(int)a andB:(long long)b { {int a = b;} }").allTokens
        
        let methods = ObjcMethodParser().parse(tokens)
        
        XCTAssert(methods.count == 1)
        
        let method = methods[0]
        XCTAssert(method.isStatic == true)
        XCTAssert(method.params.count == 2)
        XCTAssert(method.methodBody.count == 7)
    }
}
