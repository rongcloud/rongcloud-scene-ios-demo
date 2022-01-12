//
//  PlayerMediator.swift
//  RCE
//
//  Created by xuefeng on 2021/11/28.
//

import UIKit

class PlayerImpl: NSObject, RCMusicPlayer, RCRTCAudioMixerAudioPlayDelegate {
    
    enum PlayerRoomType {
        case voice
        case radio
        case live
    }
    
    static let instance = PlayerImpl()
    
    var type: PlayerRoomType = .voice
    
    //当前正在播放的音乐
    var currentPlayingMusic: RCMusicInfo?
    //当前的播放器状态
    var currentPlayState: RCRTCAudioMixingState = .mixingStateStop
    //被暂停的音乐
    var currentPausingMusic: RCMusicInfo?
    
    private override init() {
        super.init()
        RCRTCAudioMixer.sharedInstance().delegate = self
    }
    
    func localVolume() -> Int {
        return Int(RCRTCAudioMixer.sharedInstance().playingVolume)
    }
    
    func setLocalVolume(_ volume: Int) {
        RCRTCAudioMixer.sharedInstance().playingVolume = UInt(volume)
    }
    
    func remoteVolume() -> Int {
        return Int(RCRTCAudioMixer.sharedInstance().mixingVolume)
    }
    
    func setRemoteVolume(_ volume: Int) {
        RCRTCAudioMixer.sharedInstance().mixingVolume = UInt(volume)
    }
    
    func micVolume() -> Int {
        return Int(RCRTCEngine.sharedInstance().defaultAudioStream.recordingVolume)
    }
    
    func setMicVolume(_ volume: Int) {
        RCRTCEngine.sharedInstance().defaultAudioStream.recordingVolume = UInt(volume)
    }
    
    func setEarOpenMonitoring(_ on: Bool) {
        RCRTCEngine.sharedInstance().audioEffectManager.enable(inEarMonitoring: on)
    }
    
    func startMixing(with info: RCMusicInfo) -> Bool {
        
        if let pausingMusic = currentPausingMusic,
            currentPlayState == .mixingStatePause,
            pausingMusic.musicId == info.musicId {
            currentPlayingMusic = info
            return RCRTCAudioMixer.sharedInstance().resume()
        }
        
        guard let fileName = info.musicId, let musicDir = RCMusicDataPath.musicsDir(RCMusicDataPath.document()) else {
            log.debug("startMixing info fileName must be nonnull");
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
    
    func stopMixing(with info: RCMusicInfo?) -> Bool {
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
    
    func playEffect(_ soundId: Int, filePath: String) {
        RCRTCEngine.sharedInstance().audioEffectManager.stopAllEffects()
        RCRTCEngine.sharedInstance().audioEffectManager.playEffect(soundId, filePath: filePath, loopCount: 1, publish: true)
    }
    
    func didAudioMixingStateChanged(_ mixingState: RCRTCAudioMixingState, reason mixingReason: RCRTCAudioMixingReason) {
        //TODO
        //mixingState 状态不准确，已经确认是 rtc bug 下个版本修复
        //临时使用reason设置play状态
        currentPlayState = mixingReason == .mixingReasonPausedByUser ? .mixingStatePause : mixingState
    
        handleState(currentPlayState)
        
        sendCommandMessage()
        
        syncRoomPlayingMusicInfo()
        
        RCMusicEngine.shareInstance().asyncMixingState(RCMusicMixingState(rawValue: UInt(mixingState.rawValue)) ?? .playing)

    }
    
    func didReportPlayingProgress(_ progress: Float) {
        
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
            RCVoiceRoomEngine.sharedInstance().sendMessage(commandMessage) {
                log.debug(" voice 同步歌曲信息消息发送成功");
            } error: { code, msg in
                log.debug(" voice 同步歌曲信息消息发送失败 code: \(code) msg: \(msg)");
            }
        } else if (PlayerImpl.instance.type == .radio || PlayerImpl.instance.type == .live) {
            guard let roomId = DelegateImpl.instance.roomId else {
                return
            }
            RCChatroomMessageCenter.sendChatMessage(roomId, content: commandMessage) {_ in
                log.debug("radio 同步歌曲信息消息发送成功");
            } error: { eCode, mId in
                log.debug(" radio 同步歌曲信息消息发送失败 code: \(eCode) mId: \(mId)");
            }
        }
    }
    
    func syncRoomPlayingMusicInfo() {
        let info = currentPlayingMusic as? MusicInfo
        DelegateImpl.instance.syncPlayingMusicInfo(info)
    }
    
    func clear() {
        let tmp = currentPlayingMusic
        currentPlayingMusic = nil
        currentPausingMusic = nil
        if (tmp != nil) {
            let _ = stopMixing(with: nil)
        }
    }
}
