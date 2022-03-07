//
//  CreateVoiceRoomNetWorkService.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/2/18.
//

import Foundation
import RCSceneService
import RCSceneFoundation
import Moya
import SwiftUI

let createVoiceRoomNetService = CreateVoiceRoomNetWorkService()

class CreateVoiceRoomNetWorkService {
    func upload(data: Data, completion: @escaping Completion) {
        let api = RCUploadService.upload(data: data)
        uploadProvider.request(api, completion: completion)
    }
}
