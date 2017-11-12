//
//  SwiftMethodTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/12.
//

import XCTest

extension Param: Equatable {
    static func ==(lhs: Param, rhs: Param) -> Bool {
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
        guard let methods = SwiftMethodGenParser().parser.run(tokens) else {
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
}
