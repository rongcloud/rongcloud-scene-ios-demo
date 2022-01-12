//
//  VoiceRoomMusicListViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import UIKit
import RxDataSources
import ReactorKit
import SVProgressHUD

fileprivate let availableAudioFileExtensions: [String] = [
    "aac", "ac3", "aiff", "au", "m4a", "wav", "mp3"
]

class VoiceRoomMusicListViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        instance.register(cellType: VoiceRoomMusicTableViewCell.self)
        return instance
    }()
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<VoiceRoomMusicSection> = {
        return RxTableViewSectionedReloadDataSource<VoiceRoomMusicSection> {[weak self] (dataSource, tableView, indexPath, item) -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: VoiceRoomMusicTableViewCell.self)
            cell.updateCell(item: item.music, state: item.state)
            cell.rx.append.map {
                Reactor.Action.append(item.music)
            }
            .bind(to: self.reactor!.action)
            .disposed(by: cell.disposeBag)
            return cell
        }
    }()
   // private let musicSheetView = MusicSheetListView()
    
    private lazy var localMusicFileView: UIView = {
        let footerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: 64)))
        
        let iconImageView = UIImageView(image: R.image.music_local_file_icon())
        footerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        let localLabel = UILabel()
        localLabel.text = "本地上传"
        localLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        localLabel.textColor = .white
        footerView.addSubview(localLabel)
        localLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        
        let addButton = UIButton()
        addButton.addTarget(self, action: #selector(addLocalMuisc), for: .touchUpInside)
        addButton.setImage(R.image.add_music_icon(), for: .normal)
        footerView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-23.resize)
            make.width.height.equalTo(24.resize)
        }
        
        return footerView
    }()
    
    init(roomId: String) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = VoiceRoomMusicListReactor(roomId: roomId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    private func buildLayout() {
//        view.addSubview(musicSheetView)
//        musicSheetView.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(30)
//        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
          make.edges.equalToSuperview()
//            make.top.equalTo(musicSheetView.snp.bottom)
//            make.left.bottom.right.equalToSuperview()
        }
        tableView.tableFooterView = localMusicFileView
    }
    
    func bind(reactor: VoiceRoomMusicListReactor) {
        rx.viewDidLoad
            .map {
                Reactor.Action.refresh
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.error)
            .map(\.message)
            .distinctUntilChanged()
            .bind(to: SVProgressHUD.rx.errorStatus)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap(\.success)
            .map(\.message)
            .distinctUntilChanged()
            .bind(to: SVProgressHUD.rx.successStatus)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name(rawValue: MusicNotification.deleteMusic.rawValue))
            .map {
                _ in
                Reactor.Action.refresh
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.netState)
            .distinctUntilChanged()
            .subscribe(onNext: { state in
                switch state {
                case .idle: ()
                case .begin: SVProgressHUD.show(withStatus: "音乐上传中")
                case .success: SVProgressHUD.showSuccess(withStatus: "上传成功")
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
//        reactor.state
//            .map(\.channelSections)
//            .distinctUntilChanged()
//            .bind(to: musicSheetView.subject)
//            .disposed(by: disposeBag)
    }
    
    @objc private func addLocalMuisc() {
        if #available(iOS 14.0, *) {
            let types: [UTType] = availableAudioFileExtensions.compactMap { UTType(filenameExtension: $0) }
            let documentController = UIDocumentPickerViewController(forOpeningContentTypes: types)
            documentController.delegate = self
            present(documentController, animated: true, completion: nil)
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
            present(documentController, animated: true, completion: nil)
        }
    }
}

extension VoiceRoomMusicListViewController: UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first(where: { !availableAudioFileExtensions.contains($0.pathExtension) }) {
            return SVProgressHUD.showError(withStatus: "不支持的类型：" + url.pathExtension)
        }
        let musics = urls.compactMap { VoiceRoomLocalMusic.localMusic($0) }
        Observable.just(musics)
            .map { Reactor.Action.addLocalMusic($0) }
            .bind(to: reactor!.action)
            .disposed(by: disposeBag)
    }
}
