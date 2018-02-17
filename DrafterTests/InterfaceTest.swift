//
//  InterfaceTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/5.
//

import XCTest

/// 比较两个数组
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
    
    func run(_ input: String) -> [ClassNode] {
        let tokens = SourceLexer(input: input).allTokens
        guard let result = InterfaceParser().parser.toClassNode.run(tokens) else {
            XCTAssert(false)
            return []
        }
        return result
    }
    
    func testClassWithSuper() {
        let nodes = run("@interface MyClass: NSObject < Delegate1, Delegate2>")
        
        XCTAssert(nodes.count == 1)
        XCTAssert(nodes[0].superCls != nil && nodes[0].superCls! == "NSObject")
        XCTAssert(nodes[0].className == "MyClass")
        XCTAssert(nodes[0].protocols == ["Delegate1", "Delegate2"])
    }
    
    func testClassWithoutSuper() {
        let nodes = run("@interface MyClass < Delegate1, Delegate2>")
        
        XCTAssert(nodes.count == 1)
        XCTAssert(nodes[0].superCls == nil)
        XCTAssert(nodes[0].className == "MyClass")
        XCTAssert(nodes[0].protocols == ["Delegate1", "Delegate2"])
    }
    
    func testClassWithoutDelegate() {
        let nodes = run("@interface MyClass")
        
        XCTAssert(nodes.count == 1)
        XCTAssert(nodes[0].superCls == nil)
        XCTAssert(nodes[0].className == "MyClass")
        XCTAssert(nodes[0].protocols.count == 0)
    }
    
    func testCategory() {
        let nodes = run("@interface MyClass() <Delegate1, Delegate2>")
        
        XCTAssert(nodes.count == 1)
        XCTAssert(nodes[0].superCls == nil)
        XCTAssert(nodes[0].className == "MyClass")
        XCTAssert(nodes[0].protocols == ["Delegate1", "Delegate2"])
    }
    
    func testContiuous() {
        let input = """
        @interface MyClass() <Delegate1, Delegate2>
        int a = 2;
        - (void)method {
            a = b
        }
        @end
        @interface MyClass2()
        """
        
        let nodes = run(input)
        
        XCTAssert(nodes.count == 2)
        
        XCTAssert(nodes[0].superCls == nil)
        XCTAssert(nodes[0].className == "MyClass2")
        XCTAssert(nodes[0].protocols.count == 0)
        
        XCTAssert(nodes[1].className == "MyClass")
        XCTAssert(nodes[1].superCls == nil)
        XCTAssert(nodes[1].protocols == ["Delegate1", "Delegate2"])
    }
    
//    func testTokens() {
//        let input = """
//        int a = 2;
//        - (void)method {
//            a = b
//        }
//        @end
//        @interface MyClass2()
//        """
//
//        let tokens = SourceLexer(input: input).allTokens
//        let result = anyTokens(until: token(.end)).run(tokens)
//    }
}
