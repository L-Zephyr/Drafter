//
//  SwiftMethodTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/12.
//

import XCTest

extension Param: Equatable {
    public static func ==(lhs: Param, rhs: Param) -> Bool {
        return lhs.outterName == rhs.outterName
            && lhs.innerName == rhs.innerName
            && lhs.type == rhs.type
    }
}

class SwiftMethodTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func run(_ input: String) -> [MethodNode] {
        let tokens = SourceLexer(input: input, isSwift: true).allTokens
        guard let methods = SwiftMethodParser().parser.run(tokens) else {
            XCTAssert(false)
            return []
        }
        return methods
    }
    
    func testSimpleMethod() {
        let methods = run("func method() {}")
        let clsMethods = run("static func method() {}")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].isStatic == false)
        XCTAssert(methods[0].methodName == "method")
        XCTAssert(methods[0].params.count == 0)
        
        XCTAssert(clsMethods.count == 1)
        XCTAssert(clsMethods[0].isStatic == true)
        XCTAssert(clsMethods[0].methodName == "method")
        XCTAssert(clsMethods[0].params.count == 0)
    }
    
    func testInit() {
        let methods = run("init() { }")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].methodName == "init")
    }
    
    func testSimpleParam() {
        let methods = run("func method(_ a: String, b: Int, c d: Float) -> Int {}")
        
        let p1 = Param(outterName: "_", type: "String", innerName: "a")
        let p2 = Param(outterName: "b", type: "Int", innerName: "b")
        let p3 = Param(outterName: "c", type: "Float", innerName: "d")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].params.count == 3)
        XCTAssert(methods[0].params == [p1, p2, p3])
        XCTAssert(methods[0].returnType == "Int")
    }
    
    func testFuncParam() {
        let methods = run("func method(_ a: ([Int], String) -> Int, b: Float) -> ([Int]) -> String {}")
        
        let p1 = Param(outterName: "_", type: "([Int],String)->Int", innerName: "a")
        let p2 = Param(outterName: "b", type: "Float", innerName: "b")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].params.count == 2)
        XCTAssert(methods[0].params == [p1, p2])
        XCTAssert(methods[0].returnType == "([Int])->String")
    }
    
    func testDefaultValue() {
        let methods = run("func method(_ a: Int = 5, b: (Int) -> Int = MyInit) {}")
        
        let p1 = Param(outterName: "_", type: "Int", innerName: "a")
        let p2 = Param(outterName: "b", type: "(Int)->Int", innerName: "b")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].params.count == 2)
        XCTAssert(methods[0].params == [p1, p2])
    }
    
    func testWithModifier() {
        let methods = run("func method(_ a: inout Int, b: @autoclosure (Int) -> Int = MyInit) throws {}")
        
        let p1 = Param(outterName: "_", type: "Int", innerName: "a")
        let p2 = Param(outterName: "b", type: "(Int)->Int", innerName: "b")
        
        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].params.count == 2)
        XCTAssert(methods[0].params == [p1, p2])
    }

    func testInlineFunc() {
        let code = """
        func method1() { 
            func inlineFunc() { 
            
            }
            inlineFunc()
        }
        """
        let methods = run(code)

        XCTAssert(methods.count == 1)
        XCTAssert(methods[0].methodName == "method1")
        XCTAssert(methods[0].invokes.count == 2) // TIP: 暂时不处理内联函数
    }

    func testAccessControl() {
        let code = """
        func method1() {}
        static func method2() {}
        public func method3() {}
        public static func method4() {}
        static open func method5() {}
        """
        let methods = run(code)

        XCTAssert(methods.count == 5)
        XCTAssert(methods[0].isStatic == false && methods[0].accessControl == .internal)
        XCTAssert(methods[1].isStatic == true && methods[1].accessControl == .internal)
        XCTAssert(methods[2].isStatic == false && methods[2].accessControl == .public)
        XCTAssert(methods[3].isStatic == true && methods[3].accessControl == .public)
        XCTAssert(methods[4].isStatic == true && methods[4].accessControl == .open)
    }
}
