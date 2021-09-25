//
//  RCRTCAudioRecorder.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/3.
//

import UIKit
import AVFoundation

/// 参考:https://blog.csdn.net/longshihua/article/details/52312284

public final class RCRTCAudioRecorder: NSObject {
    public static let shared = RCRTCAudioRecorder()
    
    private var recorder: AVAudioRecorder?
    private var lastCategory: AVAudioSession.Category = .playAndRecord
    
    override init() {
        super.init()
        clear()
    }
    
    public func start() {
        guard permission() else { return permissionNeedOpenSetting() }
        
        let session = AVAudioSession.sharedInstance()
        lastCategory = AVAudioSession.sharedInstance().category
        do {
            try session.setCategory(.record)
            try session.setActive(true, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        let timeInterval = Int(Date().timeIntervalSince1970 * 1000)
        let path = NSTemporaryDirectory() + "/RCVRRecord_\(timeInterval).wav"
        let url = URL(fileURLWithPath: path)
        
        let recordSettings: [String: Any] = [
            AVSampleRateKey: 44100.0,
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        
        do {
            let recorder = try AVAudioRecorder(url: url, settings: recordSettings)
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            let ret = recorder.record()
            if ret {
                print("recording start")
            } else {
                print("recording fail")
            }
            self.recorder = recorder
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func stop() -> (URL, TimeInterval)? {
        guard let recorder = recorder else {
            return nil
        }
        guard recorder.isRecording else {
            return nil
        }
        let time = recorder.currentTime
        print("audio length: \(time)")
        recorder.stop()
        try? AVAudioSession.sharedInstance().setCategory(lastCategory)
        return (recorder.url, time)
    }
    
    public func cancel() {
        recorder?.stop()
        recorder?.deleteRecording()
        try? AVAudioSession.sharedInstance().setCategory(lastCategory)
    }
    
    public func clear() {
        let path = NSTemporaryDirectory()
        let contents = try? FileManager.default.contentsOfDirectory(atPath: path)
        contents?.forEach({ name in
            try? FileManager.default.removeItem(atPath: path + "/" + name)
        })
    }
    
    public func remove(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

extension RCRTCAudioRecorder {
    private func permission() -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            return false
        case .granted:
            return true
        case .undetermined:
            let semaphore = DispatchSemaphore(value: 0)
            var allowed: Bool = false
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                allowed = isAllowed
                semaphore.signal()
            }
            semaphore.wait()
            return allowed
        @unknown default: return false
        }
    }
    
    private func permissionNeedOpenSetting() {
        let alertController = UIAlertController(title: "提示", message: "请到设置 -> 隐私 -> 麦克风 ，打开访问权限", preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "", style: .default, handler: nil)
        alertController.addAction(sureAction)
        UIApplication.shared.windows
            .first(where: {$0.isKeyWindow})?
            .rootViewController?
            .present(alertController, animated: true, completion: nil)
    }
}
