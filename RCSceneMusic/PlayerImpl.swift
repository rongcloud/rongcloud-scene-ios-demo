//
//  PlayerMediator.swift
//  RCE
//
//  Created by xuefeng on 2021/11/28.
//

import UIKit
import RCSceneMessage

public class PlayerImpl: NSObject, RCMusicPlayer, RCRTCAudioMixerAudioPlayDelegate {
    
    public enum PlayerRoomType {
        case voice
        case radio
        case live
    }
    
    public static let instance = PlayerImpl()
    
    //用户耳返开关状态
    private var openEarMonitoring = false

    public var type: PlayerRoomType = .voice
    
    //当前正在播放的音乐
    public var currentPlayingMusic: RCMusicInfo?
    //当前的播放器状态
    public var currentPlayState: RCRTCAudioMixingState = .mixingStateStop
    //被暂停的音乐
    var currentPausingMusic: RCMusicInfo?
    
    private override init() {
        super.init()
        RCRTCAudioMixer.sharedInstance().delegate = self
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onRouteChanged(_:)),
                         name: AVAudioSession.routeChangeNotification,
                         object: nil)

    }
    
    public func initializedEarMonitoring() {
        setEarOpenMonitoring(openEarMonitoring)
    }

    public func localVolume() -> Int {
        return Int(RCRTCAudioMixer.sharedInstance().playingVolume)
    }
    
    public func setLocalVolume(_ volume: Int) {
        RCRTCAudioMixer.sharedInstance().playingVolume = UInt(volume)
    }
    
    public func remoteVolume() -> Int {
        return Int(RCRTCAudioMixer.sharedInstance().mixingVolume)
    }
    
    public func setRemoteVolume(_ volume: Int) {
        RCRTCAudioMixer.sharedInstance().mixingVolume = UInt(volume)
    }
    
    public func micVolume() -> Int {
        return Int(RCRTCEngine.sharedInstance().defaultAudioStream.recordingVolume)
    }
    
    public func setMicVolume(_ volume: Int) {
        RCRTCEngine.sharedInstance().defaultAudioStream.recordingVolume = UInt(volume)
    }
    
    public func setEarOpenMonitoring(_ on: Bool) {
//        RCRTCEngine.sharedInstance().audioEffectManager.enable(inEarMonitoring: on)
        openEarMonitoring = on && isHeadsetPluggedIn()
        RCMusicEngine.shareInstance().openEarMonitoring = openEarMonitoring
        RCRTCEngine.sharedInstance().audioEffectManager.enable(inEarMonitoring:openEarMonitoring)

    }
    
    public func startMixing(with info: RCMusicInfo) -> Bool {
        
        if let pausingMusic = currentPausingMusic,
            currentPlayState == .mixingStatePause,
            pausingMusic.musicId == info.musicId {
            currentPlayingMusic = info
            return RCRTCAudioMixer.sharedInstance().resume()
        }
        
        guard let fileName = info.musicId, let musicDir = DataSourceImpl.musicDir() else {
            print("startMixing info fileName must be nonnull");
            return false
        }
        var success = false
        let filePath = musicDir + "/" + fileName
        if (!FileManager.default.fileExists(atPath: filePath)) {
            DataSourceImpl.instance.fetchMusicDetail(with: info) { detail in
                guard let music = detail as? MusicInfo else {
                    return
                }
                MusicDownloader.shared.hifiveDownload(music: music) { success in
                    self.currentPlayingMusic = info;
                    let _ = RCRTCAudioMixer.sharedInstance().startMixing(with: URL(fileURLWithPath: filePath), playback: true, mixerMode: .mixing, loopCount: 1)
                }
            }
        } else {
            currentPlayingMusic = info;
            success = RCRTCAudioMixer.sharedInstance().startMixing(with: URL(fileURLWithPath: filePath), playback: true, mixerMode: .mixing, loopCount: 1)
        }
        return success
    }
    
    public func stopMixing(with info: RCMusicInfo?) -> Bool {
        if let info = info ,let currentInfo = currentPlayingMusic, info.musicId == currentInfo.musicId {
            return pause()
        }
        currentPlayingMusic = nil
        return RCRTCAudioMixer.sharedInstance().stop()
    }
    
    func pause() -> Bool {
        return RCRTCAudioMixer.sharedInstance().pause()
    }
    
    func resume() -> Bool {
        return RCRTCAudioMixer.sharedInstance().resume()
    }
    
    public func playEffect(_ soundId: Int, filePath: String) {
        RCRTCEngine.sharedInstance().audioEffectManager.stopAllEffects()
        RCRTCEngine.sharedInstance().audioEffectManager.playEffect(soundId, filePath: filePath, loopCount: 1, publish: true)
    }
    
    public func didAudioMixingStateChanged(_ mixingState: RCRTCAudioMixingState, reason mixingReason: RCRTCAudioMixingReason) {
        //TODO
        //mixingState 状态不准确，已经确认是 rtc bug 下个版本修复
        //临时使用reason设置play状态
        currentPlayState = mixingReason == .mixingReasonPausedByUser ? .mixingStatePause : mixingState
    
        handleState(currentPlayState)
                
        syncRoomPlayingMusicInfo { [weak self] in
            guard let self = self else {
                return
            }
            self.sendCommandMessage()
        }
        
        RCMusicEngine.shareInstance().asyncMixingState(RCMusicMixingState(rawValue: UInt(mixingState.rawValue)) ?? .playing)

    }
    
    public func didReportPlayingProgress(_ progress: Float) {
        
    }
    
    func handleState(_ mixingState: RCRTCAudioMixingState) {
        if (mixingState == .mixingStateStop) {
            handleStopState()
        } else if (mixingState == .mixingStatePause) {
            handlePauseState()
        }
    }
    
    func handleStopState() {
        guard let tmp = currentPlayingMusic as? MusicInfo,
              let musics = DataSourceImpl.instance.musics,
              let index = musics.firstIndex(of: tmp) else { return }
        if (index >= musics.count - 1) {
            currentPausingMusic = nil
            let _ = stopMixing(with: nil)
        } else {
            let _ = startMixing(with: musics[index+1])
        }
    }
    
    func handlePauseState() {
        currentPausingMusic = currentPlayingMusic
        currentPlayingMusic = nil
    }
    
    func sendCommandMessage() {
        //发送控制消息 同步歌曲信息到观众房间
        var musicId = 0
        if  let musicInfo = currentPlayingMusic as? MusicInfo, let id = musicInfo.id {
            musicId = id
        }
        guard let commandMessage = RCCommandMessage(name: "RCVoiceSyncMusicInfoKey", data: String(musicId)) else {
            return
        }
        if (PlayerImpl.instance.type == .voice) {
            let roomId = RCRTCEngine.sharedInstance().room.roomId
            RCCoreClient.shared().sendMessage(.ConversationType_CHATROOM, targetId: roomId, content: commandMessage, pushContent: "", pushData: "") { mId in
                print(" voice 同步歌曲信息消息发送成功");
            } error: { code, mId in
                print(" voice 同步歌曲信息消息发送失败 code: \(code) mId: \(mId)");
            }
        } else if (PlayerImpl.instance.type == .radio || PlayerImpl.instance.type == .live) {
            guard let roomId = DelegateImpl.instance.roomId else {
                return
            }

            ChatroomSendMessage(commandMessage, roomId) { result in
                switch result {
                case .success:
                    print("radio 同步歌曲信息消息发送成功");
                case .failure(let error):
                    print(" radio 同步歌曲信息消息发送失败: \(error.localizedDescription)");
                }
            }
    
        }
    }
    
    func syncRoomPlayingMusicInfo(_ completion: @escaping () -> Void) {
        let info = currentPlayingMusic as? MusicInfo
        DelegateImpl.instance.syncPlayingMusicInfo(info,completion)
    }
    
    public func clear() {
        let tmp = currentPlayingMusic
        currentPlayingMusic = nil
        currentPausingMusic = nil
        if (tmp != nil) {
            let _ = stopMixing(with: nil)
        }
    }
    
    private func isHeadsetPluggedIn() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        let isHeadsetPluggedIn = route.outputs.contains { desc in
            switch desc.portType {
            case .bluetoothLE,
                 .bluetoothHFP,
                 .bluetoothA2DP,
                 .headphones:
                return true
            default: return false
            }
        }
        return isHeadsetPluggedIn
    }
    
    @objc private func onRouteChanged(_ notification: Notification) {
        setEarOpenMonitoring(openEarMonitoring)
    }

}
