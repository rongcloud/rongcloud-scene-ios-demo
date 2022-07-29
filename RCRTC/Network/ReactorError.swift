//
//  ReactorError.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/21.
//

import Foundation

private var reactorErrorIndex = 1
public struct ReactorError: Error, Equatable, LocalizedError {
    public var errorDescription: String? {
        return message
    }
    private let id: Int
    public let message: String
    
    public init(_ message: String) {
        id = reactorErrorIndex
        reactorErrorIndex += 1
        self.message = message
    }
}

extension ReactorError: CustomStringConvertible {
    public var description: String {
        return message
    }
}
