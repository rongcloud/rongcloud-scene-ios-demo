//
//  TestCommonUtil.swift
//  RCETests
//
//  Created by 叶孤城 on 2021/4/23.
//

import XCTest
@testable import RCE

class TestCommonUtil: XCTestCase {
    private let error1 = ReactorError("hi")
    private let error2 = ReactorError("hi")
    
    private let success1 = ReactorSuccess("hi")
    private let success2 = ReactorSuccess("hi")
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testErrorIsEqual() {
        XCTAssertNotEqual(error1, error2)
    }
    
    func testSuccessIsEqual() {
        XCTAssertNotEqual(success1, success2)
    }
}
