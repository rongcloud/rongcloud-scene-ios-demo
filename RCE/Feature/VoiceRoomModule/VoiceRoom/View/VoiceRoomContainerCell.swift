//
//  VoiceRoomContainerCell.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/12.
//

import Reusable
import Kingfisher
import SVProgressHUD

final class VoiceRoomContainerCell: UICollectionViewCell, Reusable {
    private(set) lazy var backgroundImageView: AnimatedImageView = {
        let instance = AnimatedImageView()
        instance.contentMode = .scaleAspectFill
        instance.clipsToBounds = true
        instance.runLoopMode = .default
        return instance
    }()
    
    private var voiceRoom: VoiceRoom?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        NotificationNameRoomBackgroundUpdated
            .addObserver(self, selector: #selector(onBackgroundChanged(_:)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ voiceRoom: VoiceRoom) -> Self {
        backgroundColor = .black
        self.voiceRoom = voiceRoom
        let imageURL = URL(string: voiceRoom.backgroundUrl ?? "")
        updateBackgroundImage(imageURL)
        return self
    }
    
    func setup(_ view: UIView) {
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        } completion: { _ in
            self.startGiftAnimation()
        }
    }
    
    @objc private func onBackgroundChanged(_ notification: Notification) {
        guard
            let info = notification.object as? (String, String),
            voiceRoom?.roomId == info.0
        else { return }
        updateBackgroundImage(URL(string: info.1))
    }
    
    private func updateBackgroundImage(_ imageURL: URL?) {
        let targetSize = UIScreen.main.bounds.size
        let resizingProcessor = ResizingImageProcessor(referenceSize: targetSize, mode: .aspectFill)
        var options = KingfisherOptionsInfo()
        options.append(.memoryCacheExpiration(.expired))
        options.append(.onlyLoadFirstFrame)
        options.append(.processor(resizingProcessor))
        backgroundImageView.kf.setImage(with: imageURL, options: options)
    }
    
    func startGiftAnimation() {
        guard let voiceRoom = voiceRoom else { return }
        let imageURL = URL(string: voiceRoom.backgroundUrl ?? "")
        backgroundImageView.kf.setImage(with: imageURL, options: [.memoryCacheExpiration(.expired)])
    }
    
    func stopGiftAnimation() {
        guard let voiceRoom = voiceRoom else { return }
        let imageURL = URL(string: voiceRoom.backgroundUrl ?? "")
        updateBackgroundImage(imageURL)
    }
}
