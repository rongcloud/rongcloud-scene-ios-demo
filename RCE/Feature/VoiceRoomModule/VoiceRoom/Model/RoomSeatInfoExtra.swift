//
//  RoomSeatInfoExtra.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/1/25.
//

import Foundation

struct RoomSeatInfoExtra: Codable {
    let disableRecording: Bool
    func toJsonString () -> String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return nil
            }
            return jsonString
        } catch {
            print(error)
            return nil
        }
    }
}

extension RCVoiceSeatInfo {
    func decodeExtra() -> RoomSeatInfoExtra? {
        if let extra = self.extra {
            let data = Data(extra.utf8)
            return try? JSONDecoder().decode(RoomSeatInfoExtra.self, from: data)
        }
        return nil
    }
    
    var disableRecording: Bool {
        if let seatInfoExtra = self.decodeExtra() {
            return seatInfoExtra.disableRecording
        } else {
            return false
        }
    }
}
