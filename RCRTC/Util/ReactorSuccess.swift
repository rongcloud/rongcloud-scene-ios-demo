//
//  ReactorSuccess.swift
//  RCE
//
//  Created by 彭蕾 on 2022/6/14.
//

import Foundation

private var reactorSuccessIndex = 1
public struct ReactorSuccess: Equatable {
    private let id: Int
    public let message: String
    public init(_ message: String) {
        id = reactorSuccessIndex
        reactorSuccessIndex += 1
        self.message = message
    }
}
