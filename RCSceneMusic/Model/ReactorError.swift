//
//  ReactorError.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/21.
//

import Foundation

private var reactorErrorIndex = 1
struct ReactorError: Error, Equatable, LocalizedError {
    var errorDescription: String? {
        return message
    }
    private let id: Int
    let message: String
    
    init(_ message: String) {
        id = reactorErrorIndex
        reactorErrorIndex += 1
        self.message = message
    }
}

extension ReactorError: CustomStringConvertible {
    var description: String {
        return message
    }
}
