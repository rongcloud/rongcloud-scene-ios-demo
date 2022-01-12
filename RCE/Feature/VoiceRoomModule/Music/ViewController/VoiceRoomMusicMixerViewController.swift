//
//  VoiceRoomMusicMixerViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import UIKit
import RxDataSources
import RxSwift

enum MusicControlCellType {
    case local(Float)
    case remote(Float)
    case micphone(Float)
    case ear(Bool)
    
    var name: String {
        switch self {
        case .local:
            return "本端音量"
        case .remote:
            return "远端音量"
        case .micphone:
            return "麦克音量"
        case .ear:
            return "开启耳返"
        }
    }
}

struct MusicControlSection {
    var items: [MusicControlCellType]
}

extension MusicControlSection: SectionModelType {
    typealias Item = MusicControlCellType
    
    init(original: MusicControlSection, items: [MusicControlCellType]) {
        self = original
        self.items = items
    }
}

class VoiceRoomMusicMixerViewController: UIViewController {
    private var disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let instance = UITableView(frame: .zero, style: .plain)
        instance.backgroundColor = .clear
        instance.separatorStyle = .none
        instance.register(cellType: VoiceRoomMusicControlTableViewCell.self)
        return instance
    }()
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<MusicControlSection> = {
        return RxTableViewSectionedReloadDataSource<MusicControlSection> { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: VoiceRoomMusicControlTableViewCell.self)
            cell.updateCell(type: item)
            cell.sliderValueChanaged = {
                [weak self] value, type in
                self?.handleValueChagned(value: value, type: type)
            }
            cell.switchChanged = {
                [weak self] isOn in
                self?.handleEarOpening(isOn: isOn)
            }
            return cell
        }
    }()
    
    private let sectionSubject = BehaviorSubject<[MusicControlSection]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        bind()
        let localValue = player().localVolume()
        let remoteValue = player().remoteVolume()
        let recordingValue = player().micVolume()
        let sections = [MusicControlSection(items: [.local(Float(localValue)), .remote(Float(remoteValue)), .micphone(Float(recordingValue)), .ear(false)])]
        sectionSubject.onNext(sections)
    }
    
    private func buildLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        sectionSubject.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func handleValueChagned(value: Float, type: MusicControlCellType) {
        switch type {
        case .local:
            player().setLocalVolume(Int(value))
        case .remote:
            player().setRemoteVolume(Int(value))
        case .micphone:
            player().setMicVolume(Int(value))
        case .ear:
            ()
        }
    }
    
    private func handleEarOpening(isOn: Bool) {
        player().setEarOpenMonitoring(isOn)
    }
    
    private func player() -> RCMusicPlayer {
        let player = RCMusicEngine.shareInstance().player
        if (player == nil) {
            assert(false, "player 没有初始化，需要设置RCMusicEngine.player")
        }
        return player!
    }
}
