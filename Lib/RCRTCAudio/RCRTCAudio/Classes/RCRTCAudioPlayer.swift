//
//  RCRTCAudioPlayer.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/3.
//

import UIKit
import AVFoundation

public final class RCRTCAudioPlayer: NSObject {
    
    public static let shared = RCRTCAudioPlayer()
    
    private var player: AVAudioPlayer?
    /// player -> play -> set, player -> stop -> restore
    private var lastCategory: AVAudioSession.Category = .playAndRecord
    
    public var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    public var completion: (() -> Void)?
    
    override init() {
        super.init()
        clear()
    }
    
    private func resetIfPlaying() {
        guard isPlaying else { return }
        player?.stop()
        try? AVAudioSession.sharedInstance().setCategory(lastCategory)
        completion?()
        completion = nil
    }
    
    private func playDidError(_ msg: String) {
        print("play audio error: \(msg)")
        completion?()
        completion = nil
    }
    
    private func download(_ url: URL, completion: @escaping (URL) -> Void) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("url is invalite")
        }
        guard let path = components.queryItems?.first(where: { $0.name == "path" })?.value else {
            fatalError("url is not voice path")
        }
        guard let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            fatalError("doc path is not available")
        }
        let folderPath = docPath + "/voice_room_audio"
        if !FileManager.default.fileExists(atPath: folderPath) {
            try? FileManager.default.createDirectory(atPath: folderPath,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        let fileName = path.replacingOccurrences(of: "/", with: "_")
        let filePath = folderPath + "/" + fileName
        let localURL = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            return completion(localURL)
        }
        URLSession.shared.downloadTask(with: url) { fileURL, response, error in
            if let fileURL = fileURL {
                do {
                    try FileManager.default.moveItem(at: fileURL, to: localURL)
                    DispatchQueue.main.async {
                        completion(localURL)
                    }
                } catch {
                    debugPrint("move file failed:\(error.localizedDescription)")
                }
            } else {
                print("download audio file failed: \(error?.localizedDescription ?? "???")")
            }
        }
        .resume()
    }
}

extension RCRTCAudioPlayer {
    public func play(_ url: URL?, completion: @escaping () -> Void) {
        guard let url = url else { return }
        resetIfPlaying()
        self.completion = completion
        download(url) { [weak self] localURL in
            guard let self = self else { return }
            do {
                self.lastCategory = AVAudioSession.sharedInstance().category
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                try AVAudioSession.sharedInstance().setActive(true, options: [])
                let player = try AVAudioPlayer(contentsOf: localURL)
                player.delegate = self
                player.volume = 1
                let ret = player.play()
                if ret == false { self.playDidError("播放失败") }
                self.player = player
            } catch {
                self.playDidError(error.localizedDescription)
            }
        }
    }
    
    public func stop() {
        guard let player = player else { return }
        guard player.isPlaying else { return }
        player.stop()
        try? AVAudioSession.sharedInstance().setCategory(lastCategory)
    }
    
    public func isPlaying(_ path: String) -> Bool {
        guard isPlaying else { return false }
        guard let url = player?.url else { return false }
        return url.absoluteString == path
    }
    
    public func clear() {
        guard let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            fatalError("doc path is not available")
        }
        try? FileManager.default.removeItem(atPath: docPath + "/voice_room_audio")
    }
}

extension RCRTCAudioPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(lastCategory)
        if flag { completion?() }
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        try? AVAudioSession.sharedInstance().setCategory(lastCategory)
        completion?()
    }
}
