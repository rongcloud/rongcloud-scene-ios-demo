//
//  MusicDownloader.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import Foundation
import Alamofire
import SVProgressHUD
import RxSwift

final class MusicDownloader {
    static let shared = MusicDownloader()
    func download(music: VoiceRoomMusic, completion: ((Bool) -> Void)? = nil) {
        guard !FileManager.default.fileExists(atPath: music.fileURL().path) else {
            completion?(true)
            return
        }
        guard let urlString = music.url, let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) else {
            completion?(false)
            fatalError("music url is nil")
        }
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(music.name)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        AF.download(url, to: destination).downloadProgress { progress in
            SVProgressHUD.showProgress(Float(progress.fractionCompleted))
        }.response { response in
            debugPrint(response)
            if response.error == nil{
                SVProgressHUD.showSuccess(withStatus: "音乐下载成功")
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func downloadMusic(_ music: VoiceRoomMusic) -> Observable<Bool> {
        return Observable<Bool>.create { observer -> Disposable in
            self.download(music: music) { isSuccess in
                if isSuccess {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
