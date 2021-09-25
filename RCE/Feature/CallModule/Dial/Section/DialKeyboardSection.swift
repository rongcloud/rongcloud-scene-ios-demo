//
//  DialKeyboardSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import Foundation
import RxDataSources

enum DialKeyboardAction {
    case number(Int)
    case character(String)
}

extension DialKeyboardAction {
    static func dialItems() -> [DialKeyboardAction] {
        return [.number(1), .number(2), .number(3),
                .number(4), .number(5), .number(6),
                .number(7), .number(8), .number(9),
                .character("*"), .number(0), .character("#")]
    }
}

struct DialKeyboardSection {
    var items: [DialKeyboardAction]
}

extension DialKeyboardSection: SectionModelType {
    typealias Item = DialKeyboardAction
    
    init(original: DialKeyboardSection, items: [DialKeyboardAction]) {
        self = original
        self.items = items
    }
}
