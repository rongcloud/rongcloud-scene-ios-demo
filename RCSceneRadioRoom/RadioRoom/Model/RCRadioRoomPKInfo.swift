//
//  RCRadioRoomPKInfo.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/23.
//

import Foundation
import RCSceneFoundation

struct RCRadioRoomPKInfo: Codable {
    let inviterId: String
    let inviteeId: String
    let inviterRoomId: String
    let inviteeRoomId: String
}

extension RCRadioRoomPKInfo {
    var isPKer: Bool { isInviter || isInvitee }
    var isInviter: Bool { inviterId == Environment.currentUserId }
    var isInvitee: Bool { inviteeId == Environment.currentUserId }
    var otherRoomId: String? {
        if isInvitee { return inviterRoomId }
        if isInviter { return inviteeRoomId }
        return nil
    }
}

extension RCRadioRoomPKInfo {
    var jsonString: String? {
        do {
            let data = try JSONEncoder().encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    static func info(_ content: String) -> RCRadioRoomPKInfo? {
        guard let data = content.data(using: .utf8) else { return nil }
        do {
            return try JSONDecoder().decode(RCRadioRoomPKInfo.self, from: data)
        } catch {
            return nil
        }
    }
}

extension RCRadioRoomPKInfo {
    var voiceRoomPKInfo: VoiceRoomPKInfo {
        return VoiceRoomPKInfo(inviterId: inviterId,
                               inviteeId: inviteeId,
                               inviterRoomId: inviterRoomId,
                               inviteeRoomId: inviteeRoomId)
    }
}
