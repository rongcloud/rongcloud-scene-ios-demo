//
//  VoiceRoomSettingViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/6.
//

import UIKit

class VoiceRoomSettingViewController: UIViewController {
    private weak var delegate: VoiceRoomSettingProtocol?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = VoiceRoomSettingCollectionViewCell.autoSize()
        layout.minimumInteritemSpacing = 30.resize
        layout.minimumLineSpacing = 28.resize
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.contentInset = UIEdgeInsets(top: 40.resize, left: 30.resize, bottom: 40.resize, right: 30.resize)
        instance.dataSource = self
        instance.delegate = self
        instance.backgroundColor = .clear
        instance.register(cellType: VoiceRoomSettingCollectionViewCell.self)
        instance.isScrollEnabled = false
        return instance
    }()
    private lazy var container: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private lazy var arrowImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.voiceroom_setting_fold()
        return instance
    }()
    private let items: [RoomSettingItem]
    
    init(items: [RoomSettingItem], delegate: VoiceRoomSettingProtocol?) {
        self.items = items
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.roundCorners(corners: [.topLeft, .topRight], radius: 21)
    }
    
    deinit {
        print("Setting Controller deinit")
    }
    
    private func buildLayout() {
       // view.backgroundColor = R.color.hex03062F()?.withAlphaComponent(0.5)
        enableClickingDismiss()
        view.addSubview(container)
        container.addSubview(blurView)
        container.addSubview(collectionView)
        container.addSubview(arrowImageView)
        
        container.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(345.resize)
        }
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        arrowImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8.resize)
        }
    }
}

extension VoiceRoomSettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: VoiceRoomSettingCollectionViewCell.self)
        cell.updateCell(item: items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}

extension VoiceRoomSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let settingItem = items[indexPath.row]
        weak var delegate = delegate
        switch settingItem {
        case let .lockRoom(isLock):
            dismiss(animated: true) {
                delegate?.lockRoomDidClick(isLock: !isLock)
            }
        case let .muteAllSeat(isMute):
            dismiss(animated: true) {
                delegate?.muteAllSeatDidClick(isMute: !isMute)
            }
        case let .lockAllSeat(isLock):
            dismiss(animated: true) {
                delegate?.lockAllSeatDidClick(isLock: !isLock)
            }
        case let .muteSelf(isSilence):
            dismiss(animated: true) {
                delegate?.silenceSelfDidClick(isSilence: !isSilence)
            }
        case .music:
            dismiss(animated: true) {
                delegate?.musicDidClick()
            }
        case let .isFreeEnterSeat(isFree):
            dismiss(animated: true) {
                delegate?.freeMicDidClick(isFree: !isFree)
            }
        case .roomTitle:
            dismiss(animated: true) {
                delegate?.modifyRoomTitleDidClick()
            }
        case .roomBackground:
            dismiss(animated: true) {
                delegate?.modifyRoomBackgroundDidClick()
            }
        case let .lessSeatMode(isLess):
            dismiss(animated: true) {
                delegate?.lessSeatDidClick(isLess: !isLess)
            }
        case .forbidden:
            dismiss(animated: true) {
                delegate?.forbiddenDidClick()
            }
        case .suspend:
            dismiss(animated: true) {
                delegate?.suspendDidClick()
            }
        case .notice:
            dismiss(animated: true) {
                delegate?.noticeDidClick()
            }
        case .switchCamera:
            dismiss(animated: true) {
                delegate?.switchCameraDidClick()
            }
        case .retouch:
            dismiss(animated: true) {
                delegate?.retouchDidClick()
            }
        case .sticker:
            dismiss(animated: true) {
                delegate?.stickerDidClick()
            }
        case .makeup:
            dismiss(animated: true) {
                delegate?.makeupDidClick()
            }
        case .effect:
            dismiss(animated: true) {
                delegate?.effectDidClick()
            }
        }
        collectionView.reloadData()
    }
}
