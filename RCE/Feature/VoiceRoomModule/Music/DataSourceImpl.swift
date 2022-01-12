//
//  MusicDataSourceMediator.swift
//  RCE
//
//  Created by xuefeng on 2021/11/29.
//

import UIKit
import SVProgressHUD

extension String {
    func md5() -> String {
        guard self.count > 0 else {
            fatalError("md5加密无效的字符串")
        }
        let cCharArray = self.cString(using: .utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(cCharArray, CC_LONG(cCharArray!.count - 1), &uint8Array)
        let data = Data(bytes: &uint8Array, count: Int(CC_MD5_DIGEST_LENGTH))
        let base64String = data.base64EncodedString()
        return base64String
    }
}

struct BubbleMusicInfo: Codable {
    let name: String
    let author: String
    let backgroundUrl: String
}


class MusicInfo: NSObject,RCMusicInfo {

    override init() {}
    
    func encode(with coder: NSCoder) {
        coder.encode(self.fileUrl ?? "", forKey: "fileUrl")
        coder.encode(self.coverUrl ?? "", forKey: "coverUrl")
        coder.encode(self.author ?? "", forKey: "author")
        coder.encode(self.musicName ?? "", forKey: "musicName")
        coder.encode(self.size ?? "", forKey: "size")
        coder.encode(self.albumName ?? "", forKey: "albumName")
        coder.encode(self.musicId ?? "", forKey: "musicId")
    }
    
    required init?(coder: NSCoder) {
        self.fileUrl = coder.decodeObject(forKey: "fileUrl") as! String?
        self.coverUrl = coder.decodeObject(forKey: "coverUrl") as! String?
        self.author = coder.decodeObject(forKey: "author") as! String?
        self.musicName = coder.decodeObject(forKey: "musicName") as! String?
        self.size = coder.decodeObject(forKey: "size") as! String?
        self.albumName = coder.decodeObject(forKey: "albumName") as! String?
        self.musicId = coder.decodeObject(forKey: "musicId") as! String?
    }
    
    
    var fileUrl: String?
    
    var coverUrl: String?
    
    var musicName: String?
    
    var author: String?
    
    var albumName: String?
    
    var musicId: String?
    
    var size: String?
    
    var isLocal: NSNumber?
    
    //本地文件path
    var localDataFilePath: String?
    //业务需要的歌曲数字id
    var id: Int?
    
    func isEqual(toMusic music: RCMusicInfo?) -> Bool {
        guard let music = music else {
            return false
        }

        return musicId == music.musicId
    }
    
    func fullPath() -> String? {
        guard let musicId = musicId, let dir = RCMusicDataPath.musicsDir(RCMusicDataPath.document()) else {
            return nil
        }
        return dir + "/" + musicId
    }
    
    static func localMusic(_ fileURL: URL) -> MusicInfo? {
        let filePath = RCMusicDataPath.musicsDir(RCMusicDataPath.document())
        guard var filePath = filePath else {
            return nil
        }
        do {
            guard fileURL.startAccessingSecurityScopedResource() else {
                return nil
            }
            var name = fileURL.lastPathComponent
            var author = ""
            filePath = filePath + "/" + name
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            try FileManager.default.copyItem(at: fileURL, to: URL(fileURLWithPath: filePath))
            let asset = AVURLAsset(url: URL(fileURLWithPath: filePath))
            for format in asset.availableMetadataFormats {
                let metadata = asset.metadata(forFormat: format)
                for item in metadata {
                    if item.commonKey?.rawValue == "title" {
                        name = item.value as? String ?? ""
                    } else if item.commonKey?.rawValue == "artist" {
                        author = item.value as? String ?? ""
                    }
                }
            }
            
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            let fileSize = attribute[.size] as? Int ?? 0
            
            let info = MusicInfo()
            info.musicName = name
            info.author = author
            info.size = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
            info.musicId = (info.musicName! + info.size!).md5()
            info.localDataFilePath = fileURL.relativePath;
            let _ = fileURL.startAccessingSecurityScopedResource()
            
            return info
        } catch {
            return nil
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let musicInfo = object as? MusicInfo else {
            return false
        }
        return musicId == musicInfo.musicId
    }
}

class MusicCategoryInfo: NSObject, RCMusicCategoryInfo {
    
    var categoryId: String?
    
    var categoryName: String?
    
    var selected: Bool
    
    override init() {
        selected = false
        super.init()
    }
}

class EffectInfo: NSObject, RCMusicEffectInfo {
    var effectName: String?
    
    var filePath: String?
    
    var soundId: Int
    
    override init() {
        soundId = 0
        super.init()
    }
}

class DataSourceImpl: NSObject, RCMusicEngineDataSource {
    
    static let instance = DataSourceImpl()

    var roomId: String?
    
    var musics: Array<MusicInfo>?
    
    //当前房间列表的所有音乐，结束直播时需要清空该列表
    var ids: Set<String> = Set()
    
    var groupId: String?
    
    func dataSourceInitialized() {
        HFOpenApiManager.shared().registerApp(withAppId: "6f78321c38ee4db3bb4dae7e56d464b1", serverCode: "ca41ad68e8054610a2", clientId: Environment.currentUserId, version: "V4.1.2") { _ in
            log.verbose("register hifive success")
        } fail: { _ in
            fatalError("register hifive failed")
        }
    }
    
    func fetchCategories(_ completion: @escaping ([Any]?) -> Void) {
        
        
        DispatchQueue.global().async {
            
            let sem = DispatchSemaphore.init(value: 0)
            
            HFOpenApiManager.shared().channel { response in
                guard let channels = response as? Array<Dictionary<String, String>> else {
                    return completion(nil)
                }
                if (channels.count > 0) {
                    let channel = channels[0]
                    self.groupId = channel["groupId"];
                }
                sem.signal()
            } fail: { error in
                log.debug("DataSourceImpl fetch groupId fail")
                SVProgressHUD.showError(withStatus: "获取歌曲类别失败")
                sem.signal()
                completion(nil)
            }
            
            let _ = sem.wait(timeout: .now() + 20)
            
            guard let groupId = self.groupId else {
                log.debug("DataSourceImpl groupId is nil")
                return completion(nil)
            }
            
            HFOpenApiManager.shared().channelSheet(withGroupId: groupId, language: "0", recoNum: nil, page: "1", pageSize: "100") { response in
                guard let response = response as? [AnyHashable : Any], let data = RCMusicSheetData.yy_model(with: response), let records = data.record else {
                    return completion(nil)
                }
                
                var result = Array<MusicCategoryInfo>()
                
                if (records.count > 0) {
                    for record in records {
                        let categoryInfo = MusicCategoryInfo()
                        categoryInfo.categoryName = record.sheetName
                        categoryInfo.categoryId = record.sheetId?.stringValue
                        result.append(categoryInfo)
                    }
                }
                completion(result)
                log.debug("DataSourceImpl fetch categories success")
            } fail: { error  in
                log.debug("DataSourceImpl fetch categories failed \(error.debugDescription)")
            }
        }
    }
    
    
    func fetchOnlineMusics(byCategoryId categoryId: String, completion: @escaping ([Any]?) -> Void) {
        HFOpenApiManager.shared().sheetMusic(withSheetId: categoryId, language: "0", page: "1", pageSize: "100") { response in
            guard let response = response as? [AnyHashable : Any], let data = RCMusicData.yy_model(with: response), let records = data.record else {
                SVProgressHUD.showError(withStatus: "在线歌曲获取失败")
                return completion(nil)
            }
            var result = Array<MusicInfo>()
            
            if (records.count > 0) {
                for record in records {
                    let musicInfo = MusicInfo()
                    musicInfo.coverUrl = record.coverUrl;
                    musicInfo.musicName = record.musicName;
                    musicInfo.author = record.authorName;
                    musicInfo.albumName = record.albumName;
                    musicInfo.musicId = record.musicId;
                    result.append(musicInfo)
                }
            }
            completion(result)
            log.debug("DataSourceImpl fetch musics success")
        } fail: { error in
            log.debug("DataSourceImpl fetch musics failed \(error?.localizedDescription ?? "")")
            SVProgressHUD.showError(withStatus: "在线歌曲获取失败")
        }
    }
    
    
    func fetchCollectMusics(_ completion: @escaping ([Any]?) -> Void) {
        guard let roomId = DataSourceImpl.instance.roomId else {
            log.debug("DataSourceImpl fetch collection musics failed roomId is nil")
            SVProgressHUD.showError(withStatus: "收藏歌曲获取失败，roomId不能为空")
            return completion(nil)
        }
        
        networkProvider.request(.musiclist(roomId: roomId, type: 1)) { result in
            switch result.map(RCNetworkWapper<[VoiceRoomMusic]>.self) {
                case let .success(wrapper):
                    if let musics = wrapper.data {
                        var _result = Array<MusicInfo>()
                        for music in musics {
                            let musicInfo = MusicInfo()
                            musicInfo.fileUrl = music.url
                            musicInfo.musicName = music.name
                            musicInfo.author = music.author
                            musicInfo.albumName = "无"
                            musicInfo.size = music.size
                            musicInfo.musicId = music.thirdMusicId
                            musicInfo.coverUrl = music.backgroundUrl
                            musicInfo.id = music.id
                            _result.append(musicInfo)
                            if (musicInfo.musicId != nil) {
                                DataSourceImpl.instance.ids.insert(musicInfo.musicId!)
                            }
                        }
                        if (DelegateImpl.instance.autoPlayMusic) {
                            DelegateImpl.instance.autoPlayMusic = false
                            if let info = _result.first {
                                let _ = PlayerImpl.instance.startMixing(with: info)
                            }
                        }
                        DataSourceImpl.instance.musics = _result
                        completion(_result)
                    } else {
                        completion(nil)
                        SVProgressHUD.showError(withStatus: "收藏歌曲获取失败，roomId不能为空")
                    }
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    completion(nil)
            }
        }
    }
    

    
    func fetchMusicDetail(with info: RCMusicInfo, completion: @escaping (RCMusicInfo?) -> Void) {
        guard let musicId = info.musicId else {
            log.debug("参数错误，音乐ID为空")
            SVProgressHUD.showError(withStatus: "参数错误，音乐ID为空")
            completion(nil)
            return
        }
        
        RCMusicDataManager.trafficHQListen(withMusicId: musicId, audioFormat: nil, audioRate: nil) { detail in
            log.debug("success")
            guard let detail = detail else {
                return completion(nil)
            }
            info.fileUrl = detail.fileUrl
            info.size = ByteCountFormatter.string(fromByteCount: Int64(detail.fileSize), countStyle: .file)
            completion(info)
        } fail: { error in
            log.debug("fail")
            SVProgressHUD.showError(withStatus: "音乐详情获取失败 code:\(error?.localizedDescription ?? "")")
        }
    }
    
    func fetchSearchResult(withKeyWord keyWord: String, completion: @escaping ([Any]?) -> Void) {
        RCMusicDataManager.searchMusic(withKeyWord: keyWord) { records, error in
            guard let records = records else {
                SVProgressHUD.showError(withStatus: "搜索结果获取失败 code:\(error.localizedDescription)")
                return completion(nil)
            }
            if (records.count > 0) {
                var result = Array<MusicInfo>()
                for record in records {
                    let info = MusicInfo()
                    info.coverUrl = record.coverUrl
                    info.musicName = record.musicName
                    info.author = record.authorName
                    info.albumName = record.albumName
                    info.musicId = record.musicId
                    result.append(info)
                }
                completion(Array(result))
            }
        }
    }
    
    func fetchRoomPlayingMusicInfo(completion: @escaping (MusicInfo?) -> Void) {
        guard let roomId = roomId else {
            log.debug("获取直播间正在播放的音乐信息失败，roomId不能为空")
            return
        }
        let api: RCNetworkAPI = .fetchRoomPlayingMusicInfo(roomId: roomId)
        networkProvider.request(api) { result in
            switch result.map(RCNetworkWapper<BubbleMusicInfo>.self) {
                case let .success(wrapper):
                if let data = wrapper.data {
                    log.debug("获取直播间正在播放的音乐信息失败,数据为空")
                    let info = MusicInfo()
                    info.musicName = data.name
                    info.coverUrl = data.backgroundUrl
                    info.author = data.author
                    completion(info)
                }
                case let .failure(error):
                    log.debug("获取直播间正在播放的音乐信息失败 error\(error)")
                    completion(nil)
            }
        }
    }
    
    func musicIsExist(_ info: RCMusicInfo) -> Bool {
        guard let _ = DataSourceImpl.instance.musics, let musicId = info.musicId else {
            return false
        }
        
        return DataSourceImpl.instance.ids.contains(musicId)
    }
    
    func fetchSoundEffects(completion: @escaping ([Any]?) -> Void) {

        let bundle = Bundle(for: RCMusicEngine.classForCoder())
        
        let resourcePath = bundle.resourcePath
        
        guard let resourcePath = resourcePath else {
            SVProgressHUD.showError(withStatus: "当前没有特效资源")
            completion(nil)
            return
        }
        
        let bundlePath = resourcePath + "/" + "RCMusicControlKit.bundle" + "/" + "RCMusicSource.bundle"
        
        let info1 = EffectInfo()
        info1.soundId = 1
        info1.filePath = bundlePath + "/intro_effect.mp3"
        info1.effectName = "进场"
        
        let info2 = EffectInfo()
        info2.soundId = 2
        info2.filePath = bundlePath + "/cheering_effect.mp3"
        info2.effectName = "欢呼"
        
        let info3 = EffectInfo()
        info3.soundId = 3
        info3.filePath = bundlePath + "/clap_effect.mp3"
        info3.effectName = "鼓掌"
        
        completion([info1,info2,info3])
    }
    
    
    func addLocalMusic(_ rootViewController: UIViewController) {
        presentLocalMusicPicker(rootViewController)
    }
    
    fileprivate let availableAudioFileExtensions: [String] = [
        "aac", "ac3", "aiff", "au", "m4a", "wav", "mp3"
    ]
    
    @objc private func presentLocalMusicPicker(_ rootViewController: UIViewController) {
        if #available(iOS 14.0, *) {
            let types: [UTType] = availableAudioFileExtensions.compactMap { UTType(filenameExtension: $0) }
            let documentController = UIDocumentPickerViewController(forOpeningContentTypes: types)
            documentController.delegate = self
            rootViewController.present(documentController, animated: true, completion: nil)
        } else {
            let types = [
                "public.audio",
                "public.mp3",
                "public.mpeg-4-audio",
                "com.apple.protected-​mpeg-4-audio ",
                "public.ulaw-audio",
                "public.aifc-audio",
                "public.aiff-audio",
                "com.apple.coreaudio-​format"
            ]
            let documentController = UIDocumentPickerViewController(documentTypes: types, in: .open)
            documentController.delegate = self
            rootViewController.present(documentController, animated: true, completion: nil)
        }
    }
    
    func clear() {
        DataSourceImpl.instance.ids.removeAll()
        DataSourceImpl.instance.musics = nil
    }
}

extension DataSourceImpl: UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first(where: { !availableAudioFileExtensions.contains($0.pathExtension) }) {
            return SVProgressHUD.showError(withStatus: "不支持的类型：" + url.pathExtension)
        }
        let musics = urls.compactMap {
            MusicInfo.localMusic($0)
        }
        
        DispatchQueue.global().async {
            for music in musics {
                if (music.localDataFilePath != nil) {
                    DelegateImpl.instance.downloadedMusic(music) { success in
                        if (success) {
                            SVProgressHUD.showSuccess(withStatus: "本地文件上传成功")
                        } else {
                            SVProgressHUD.showError(withStatus: "本地文件上传失败")
                        }
                    }
                }
            }
        }
        
    }
}