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
    
    func run(_ input: String) -> [MethodNode] {
        let tokens = SourceLexer(input: input).allTokens
        guard let result = ObjcMethodParser().parser.run(tokens) else {
            XCTAssert(false)
            return []
        }
        return result
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
        let methods = run("+ (_nonable NSString *)add:(int)a andB:(long long)b;")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].isStatic == true)
        XCTAssert(methods[0].params.count == 2)
    }
    
    func testMethodDeclNoParam() {
        let methods = run("+ (_nonable NSString *)method;")
        
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
        let methods = run(input)
        
        guard methods.count == 2 else {
            XCTAssert(false)
            return
        }
        XCTAssert(methods[0].isStatic == true)
        XCTAssert(methods[0].params.count == 2)
        XCTAssert(methods[1].isStatic == false)
        XCTAssert(methods[1].params.count == 1)
    }
    
    func testMethodDef() {        
        let methods = run("+ (_nonable NSString *)add:(int)a andB:(long long)b { {int a = b;} }")
        
        XCTAssert(methods.count == 1)
        
        let method = methods[0]
        XCTAssert(method.isStatic == true)
        XCTAssert(method.params.count == 2)
    }
    
    func testMethodWithInvokes() {
        let input = """
        + (_nonable NSString *)add:(int)a andB:(long long)b {
            [self method: [self add]];
            int a = 1;
            [self method2];
            [[self method3] method4];
        }
        """
        let methods = run(input)
        
        XCTAssert(methods.count == 1)
        
        let method = methods[0]
        XCTAssert(method.isStatic == true)
        XCTAssert(method.params.count == 2)
        XCTAssert(method.invokes.count == 5)
    }
}
