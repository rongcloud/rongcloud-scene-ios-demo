//
//  ReactorSuccess.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/21.
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
