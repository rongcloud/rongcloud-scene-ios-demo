//
//  SelectRoomBackgroundSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/25.
//

import Foundation
import RxDataSources

struct SelectRoomBackgroundSection {
    var items: [Item]
}

extension SelectRoomBackgroundSection: SectionModelType {
    typealias Item = String
    
    init(original: SelectRoomBackgroundSection, items: [String]) {
        self = original
        self.items = items
    }
}

extension SelectRoomBackgroundSection: Equatable {
    
}
