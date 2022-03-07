//
//  DialSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/6/30.
//

import Foundation
import RxDataSources

public struct DialHistory: Equatable, Codable {
    let userId: String
    let avatar: String
    let date: Date
    let number: String
    
    var dateString: String {
        if Calendar.current.isDateInToday(date) {
            let dateFormmater = DateFormatter()
            dateFormmater.dateFormat = "HH:mm"
            return dateFormmater.string(from: date)
        }
        
        if Calendar.current.isDateInYesterday(date) {
            return "昨天"
        }
        
        if Date().timeIntervalSince(date) <= 24 * 60 * 60 * 7 {
            let weekday = Calendar.current.component(.weekday, from: date)
            let days: [String] = ["日", "一", "二", "三", "四", "五", "六"]
            return "星期\(days[weekday - 1])"
        }
        
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "yyyy:MM:dd"
        return dateFormmater.string(from: date)
    }

    public var user: DialUser {
        return DialUser(uid: userId, name: "", portrait: avatar, mobile: number)
    }
}

enum DialSection {
    case historySection(items: [DialHistory])
}

extension DialSection: SectionModelType {
    typealias Item = DialHistory
    
    var items: [DialHistory] {
        switch self {
        case let .historySection(items): return items
        }
    }
    
    init(original: DialSection, items: [Item]) {
        switch original {
        case let .historySection(items):
            self = .historySection(items: items)
        }
    }
}
