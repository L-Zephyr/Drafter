//
//  OCProtocolTest.swift
//  Drafter
//
//  Created by LZephyr on 2018/9/22.
//
//

import XCTest

let code1 = """
@protocol MyProtocol

@end
"""

let code2 = """
@protocol MyProtocol <NSObject>

@end
"""

class OCProtocolTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func parse(code: String) -> [ProtocolNode] {
        let tokens = SourceLexer(input: code, isSwift: false).allTokens
        guard let protos = ObjcProtocolParser().parser.run(tokens) else {
            XCTAssert(false)
            return []
        }
        return protos
    }

    func testEmptyProtocol() {
        let code = """
        @protocol MyProtocol
        
        @end
        """
        let proto = parse(code: code)

        XCTAssert(proto.count == 1)
        XCTAssert(proto[0].name == "MyProtocol")
        XCTAssert(proto[0].supers.count == 0)
        XCTAssert(proto[0].methods.count == 0)
    }

    func testProtocol1() {
        let code = """
        @protocol MyProtocol <NSObject>
        
        @end
        """
        let proto = parse(code: code)

        XCTAssert(proto.count == 1)
        XCTAssert(proto[0].name == "MyProtocol")
        XCTAssert(proto[0].supers.count == 1 && proto[0].supers[0] == "NSObject")
    }

    func testProtocol2() {
        let code = """
        @protocol MyProtocol <NSObject, UITableViewDelegate>
        
        - (void)method1;
        - (void)method2:(int)param;
        
        @end
        """
        let proto = parse(code: code)

        XCTAssert(proto.count == 1)
        XCTAssert(proto[0].name == "MyProtocol")
        XCTAssert(proto[0].supers == ["NSObject", "UITableViewDelegate"])
        XCTAssert(proto[0].methods.count == 2)
    }
}
