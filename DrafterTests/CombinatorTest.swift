//
//  TestCombinator.swift
//  DrafterTests
//
//  Created by LZephyr on 2017/11/1.
//

import XCTest

class CombinatorTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func run(_ input: String) {
//
//    }

    func testSeparator1() {
        let tokens: [Token] = [Token(type: .name, text: "name1"),
                               Token(type: .comma, text: ","),
                               Token(type: .name, text: "name2"),
                               Token(type: .comma, text: ",")]
        let comma = token(.comma)
        let parser = token(.name).separateBy(comma)
        
        if case .failure(_) = parser.parse(tokens) {
            XCTAssert(true)
        }
    }
    
    func testSeparator2() {
        let tokens: [Token] = [Token(type: .name, text: "name1"),
                               Token(type: .comma, text: ","),
                               Token(type: .name, text: "name2")]
        let comma = token(.comma)
        let parser = token(.name).separateBy(comma)
        
        guard case .success(let (result, rest)) = parser.parse(tokens) else {
            XCTAssert(true)
            return
        }
        XCTAssert(result.count == 2)
        XCTAssert(rest.count == 0)
    }

    func testBetween() {
        let tokens: [Token] = [Token(type: .leftBrace, text: "{"),
                               Token(type: .name, text: "name"),
                               Token(type: .rightBrace, text: "}")]
        let parser = token(.name).between(token(.leftBrace), token(.rightBrace))
        guard case .success(let (result, rest)) = parser.parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.type == .name)
        XCTAssert(result.text == "name")
        XCTAssert(rest.count == 0)
    }
    
    func testMany() {
        let tokens: [Token] = [Token(type: .name, text: "name1"),
                               Token(type: .name, text: "name2")]
        guard case .success(let (result, rest)) = token(.name).many.parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.count == 2)
        XCTAssert(result[0].text == "name1")
        XCTAssert(result[1].text == "name2")
        XCTAssert(rest.count == 0)
    }
    
    func testAnyToken() {
        let tokens = [Token(type: .name, text: "name"),
                      Token(type: .comma, text: ",")]
        guard case .success(let (result, rest)) = anyToken.parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.type == .name)
        XCTAssert(rest.count == 1)
    }
    
    func testNotFollowedBy() {
        let tokens = [Token(type: .name, text: "name"),
                      Token(type: .comma, text: ",")]
        guard case .success(let (result, rest)) = token(.name).notFollowedBy(token(.colon)).parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.type == .name)
        XCTAssert(rest.count == 1)
    }
    
    func testChioce() {
        let tokens = [Token(type: .name, text: "name"),
                      Token(type: .comma, text: ",")]
        guard case .success(let (result, rest)) = choice([token(.comma), token(.name)]).parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.type == .name)
        XCTAssert(rest.count == 1)
    }
    
    func testLookAhead() {
        let tokens = [Token(type: .name, text: "name"),
                      Token(type: .comma, text: ",")]
        guard case .success(let (result, rest)) = lookAhead(token(.name)).parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.type == .name)
        XCTAssert(rest.count == 2)
    }
    
    // MARK: - AnyToken
    
    func testAnyTokenUntil() {
        let tokens = [Token(type: .name, text: "name"),
                      Token(type: .comma, text: ","),
                      Token(type: .colon, text: ":")]
        guard case .success(let (result, rest)) = anyTokens(until: { $0.type == .colon}).parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.count == 2)
        XCTAssert(rest.count == 1)
    }
    
    func testAnyTokenUntil2() {
        let tokens = [Token(type: .name, text: "name"),
                      Token(type: .comma, text: ","),
                      Token(type: .colon, text: ":")]
        guard case .success(let (result, rest)) = anyTokens(until: token(.colon)).parse(tokens) else {
            XCTAssert(false)
            return
        }
                
        XCTAssert(result.count == 2)
        XCTAssert(rest.count == 1)
    }
    
    func testAnyTokenInside() {
        let tokens = SourceLexer(input: "(name1 name2 (name3)())").allTokens
        
        let l = token(.leftParen)
        let r = token(.rightParen)
        guard case .success(let (result, rest)) = anyTokens(inside: l, and: r).parse(tokens) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(result.count == 7)
        XCTAssert(rest.count == 0)
    }

    func testReduce() {
        let tokens = SourceLexer(input: "name1.name2.name3;").allTokens
        
        let single = token(.name) <* token(.dot)
        let parser =
            single.reduce([]) { (last, current) in
                return last + [current]
            }.flatMap { (results) -> Parser<[Token]> in
                return { results + [$0] } <^> token(.name)
            }
        
        guard case let .success((result, rest)) = parser.parse(tokens) else {
            XCTAssert(false)
            return
        }
        XCTAssert(result.count == 3)
        XCTAssert(rest.count == 1)
    }
}
