//
//  PreprocessorTest.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/9/2.
//

import XCTest

let ocCode = """
@interface MyClass1: NSObject
- (void)method1;
@end

@implementation MyClass1
- (void)method1 {}
@end

@interface MyClass1 (Category)
- (void)method2;
@end

@implementation MyClass1 (Category)
- (void)method2 {}
@end
"""

let swiftCode = """
class MyClass2: MyProtocol1 {
    func method1() {}
}

extension MyClass2: MyProtocol2 {
    func method2() {}
}

protocol MyProtocol1 {}
"""

class PreprocessorTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testPreprocessor() {
        let _ = Drafter()
        let ocLexer = SourceLexer(input: ocCode, isSwift: false)
        let swiftLexer = SourceLexer(input: swiftCode, isSwift: true)
        
        guard let ocTypes = ObjcTypeParser().parser.run(ocLexer.allTokens) else {
            XCTAssert(false)
            return
        }
        guard let swiftTypes = SwiftTypeParser().parser.run(swiftLexer.allTokens) else {
            XCTAssert(false)
            return
        }
        
        let ocNodes = FileNode(md5: "",
                               drafterVersion: DrafterVersion,
                               path: "",
                               type: .m,
                               swiftTypes: [],
                               objcTypes: ocTypes)
        let swiftNodes = FileNode(md5: "",
                               drafterVersion: DrafterVersion,
                               path: "",
                               type: .swift,
                               swiftTypes: swiftTypes,
                               objcTypes: [])
        
        let classes = Preprocessor.shared.process([ocNodes, swiftNodes])
        
        
    }
}
