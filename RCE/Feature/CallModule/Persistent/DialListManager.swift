//
//  DialListManager.swift
//  RCE
//
//  Created by 叶孤城 on 2021/7/6.
//

import Foundation

private let callModuleDialListKey = "callModuleDialListKey"
extension UserDefaults {
    func appendDial(_ history: DialHistory) {
        var historys = UserDefaults.standard.historyList()
        if let index = historys.firstIndex(where: { $0.number == history.number }) {
            historys.remove(at: index)
        }
        historys.append(history)
        guard let data = try? JSONEncoder().encode(historys) else { return }
        UserDefaults.standard.setValue(data, forKey: callModuleDialListKey)
    }
    
    func historyList() -> [DialHistory] {
        guard
            let data = UserDefaults.standard.data(forKey: callModuleDialListKey),
            let list = try? JSONDecoder().decode([DialHistory].self, from: data)
        else { return [] }
        return list.sorted { $0.date.timeIntervalSince($1.date) > 0 }
    }
}
