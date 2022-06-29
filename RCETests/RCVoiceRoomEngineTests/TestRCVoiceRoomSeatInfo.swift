//
//  TestRCVoiceRoomSeatInfo.swift
//  RCETests
//
//  Created by 叶孤城 on 2021/4/23.
//

import XCTest
@testable import RCE

class TestRCVoiceRoomSeatInfo: XCTestCase {
  private let seatInfo = RCMicSeatInfo()
  override func setUpWithError() throws {
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testSeatInfoCopy() {
    seatInfo.isMuted = true
    seatInfo.userJSON = "test json"
    let seatInfo2 = seatInfo.copy()
   
  }
}
