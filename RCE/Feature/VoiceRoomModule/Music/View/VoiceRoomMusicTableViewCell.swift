//
//  VoiceRoomMusicTableViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import UIKit
import Reusable
import RxSwift
import RxGesture

enum MusicListState {
    case notAdd
    case added
    case couldDelete
    case playing
    
    var image: UIImage? {
        switch self {
        case .notAdd:
            return R.image.add_music_icon()
        case .added:
            return R.image.added_music_icon()
        case .couldDelete:
            return R.image.delete_music_icon()
        case .playing:
            return R.image.playing_music_icon()
        }
    }
}

class VoiceRoomMusicTableViewCell: UITableViewCell, Reusable {
    var disposeBag = DisposeBag()
    fileprivate lazy var thumbMusicImageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        instance.image = R.image.music_thumb_icon()
        return instance
    }()
    private lazy var musicNameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 15, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var musicAuthorLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 12)
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        return instance
    }()
    private lazy var musicSizeLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 9)
        instance.textColor = UIColor.white.withAlphaComponent(0.7)
        return instance
    }()
    fileprivate lazy var stateButton: UIButton = {
        let instance = UIButton()
        return instance
    }()
    fileprivate lazy var separatorline: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return instance
    }()
    fileprivate var currentState: MusicListState!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func buildLayout() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(thumbMusicImageView)
        contentView.addSubview(musicNameLabel)
        contentView.addSubview(musicAuthorLabel)
        contentView.addSubview(musicSizeLabel)
        contentView.addSubview(stateButton)
        contentView.addSubview(separatorline)
        
        thumbMusicImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 48))
            make.top.bottom.equalToSuperview().inset(8)
            make.left.equalToSuperview().offset(23)
        }
        
        musicNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalTo(thumbMusicImageView.snp.right).offset(12)
        }
        
        musicAuthorLabel.snp.makeConstraints { make in
            make.left.equalTo(musicNameLabel)
            make.centerY.equalToSuperview()
        }
        
        musicSizeLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(4)
            make.left.equalTo(musicNameLabel)
        }
        
        stateButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(23.resize)
            make.width.height.equalTo(24.resize)
            make.centerY.equalToSuperview()
        }
        
        separatorline.snp.makeConstraints { make in
            make.left.equalTo(musicNameLabel)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    public func updateCell(item: VoiceRoomMusic, state: MusicListState) {
        self.currentState = state
        musicNameLabel.text = item.name
        musicAuthorLabel.text = item.author
        musicSizeLabel.text = item.size + "M"
        stateButton.setImage(state.image, for: .normal)
        if state == .couldDelete {
            thumbMusicImageView.image = R.image.music_play_control_icon()
        }
        if state == .playing {
            thumbMusicImageView.image = R.image.music_pause_control_icon()
        }
    }
}

import RxCocoa

extension Reactive where Base: VoiceRoomMusicTableViewCell {
    var append: Observable<Void> {
        return base.stateButton.rx.tap.filter {
            base.currentState == .notAdd
        }.asObservable()
    }
    
    var delete: Observable<Void> {
        return base.stateButton.rx.tap.filter {
            base.currentState == .couldDelete
        }.asObservable()
    }
    
    var play: Observable<UITapGestureRecognizer> {
        return base.thumbMusicImageView.rx.tapGesture().when(.recognized).filter {_ in
            base.currentState == .couldDelete
        }.asObservable()
    }
    
    var pause: Observable<UITapGestureRecognizer> {
        return base.thumbMusicImageView.rx.tapGesture().when(.recognized).filter {_ in
            base.currentState == .playing
        }.asObservable()
    }
}

final class VoiceRoomAddedMusicCell: VoiceRoomMusicTableViewCell {
    fileprivate lazy var moveButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.music_stick_icon(), for: .normal)
        return instance
    }()
    
    private lazy var playingLayer = VoiceRoomMusicPlayingLayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(moveButton)
        moveButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(stateButton.snp.left).offset(-15.resize)
            make.width.height.equalTo(24.resize)
        }
        contentView.layer.addSublayer(playingLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlayingLayer()
    }
    
    private func updatePlayingLayer() {
        guard bounds.width > 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let x = bounds.width - 23.resize - 24.resize
        let y = (bounds.height - 24.resize) * 0.5
        playingLayer.frame = CGRect(x: x, y: y, width: 24.resize, height: 24.resize)
        CATransaction.commit()
    }
    
    public override func updateCell(item: VoiceRoomMusic, state: MusicListState) {
        super.updateCell(item: item, state: state)
        stateButton.isHidden = state == .playing
        moveButton.isHidden = state == .playing
        if state == .playing {
            playingLayer.startAnimation()
        } else {
            playingLayer.stopAnimation()
        }
        if state == .couldDelete {
            thumbMusicImageView.image = R.image.music_play_control_icon()
        }
        if state == .playing {
            thumbMusicImageView.image = R.image.music_pause_control_icon()
        }
    }
}

import RxCocoa

extension Reactive where Base: VoiceRoomAddedMusicCell {
    var stick: ControlEvent<Void> {
        return base.moveButton.rx.tap
    }
}

final class VoiceRoomMusicPlayingLayer: CALayer {
    private lazy var line1Layer = CALayer()
    private lazy var line2Layer = CALayer()
    private lazy var line3Layer = CALayer()
    private lazy var line4Layer = CALayer()
    
    override init() {
        super.init()
        masksToBounds = true
        addSublayer(line1Layer)
        addSublayer(line2Layer)
        addSublayer(line3Layer)
        addSublayer(line4Layer)
        line1Layer.backgroundColor = UIColor.red.cgColor
        line2Layer.backgroundColor = UIColor.red.cgColor
        line3Layer.backgroundColor = UIColor.red.cgColor
        line4Layer.backgroundColor = UIColor.red.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateLayers()
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
    }
    
    private func updateLayers() {
        guard bounds.width > 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let lineWidth: CGFloat = 2
        let xSpace: CGFloat = (bounds.width - lineWidth) / 3.0
        line1Layer.frame = CGRect(x: xSpace * 0, y: bounds.height, width: lineWidth, height: bounds.height)
        line2Layer.frame = CGRect(x: xSpace * 1, y: bounds.height, width: lineWidth, height: bounds.height)
        line3Layer.frame = CGRect(x: xSpace * 2, y: bounds.height, width: lineWidth, height: bounds.height)
        line4Layer.frame = CGRect(x: xSpace * 3, y: bounds.height, width: lineWidth, height: bounds.height)
        CATransaction.commit()
    }
    
    func startAnimation() {
        let line1Animation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "position.y")
            animation.keyTimes = [0, 0.5, 1.0]
            animation.values = [12.resize, 30.resize, 12.resize]
            animation.duration = 1.0
            animation.repeatCount = MAXFLOAT
            animation.isRemovedOnCompletion = false
            return animation
        }()
        line1Layer.add(line1Animation, forKey: "animation")
        
        let line2Animation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "position.y")
            animation.keyTimes = [0, 0.5, 1.0]
            animation.values = [28.resize, 18.resize, 28.resize]
            animation.duration = 1.0
            animation.repeatCount = MAXFLOAT
            animation.isRemovedOnCompletion = false
            return animation
        }()
        line2Animation.timeOffset = 0.2
        line2Layer.add(line2Animation, forKey: "animation")
        
        let line3Animation = line1Animation
        line3Animation.timeOffset = 0.4
        line3Layer.add(line3Animation, forKey: "animation")
        
        let line4Animation = line2Animation
        line4Animation.timeOffset = 0.6
        line4Layer.add(line4Animation, forKey: "animation")
    }
    
    func stopAnimation() {
        line1Layer.removeAllAnimations()
        line2Layer.removeAllAnimations()
        line3Layer.removeAllAnimations()
        line4Layer.removeAllAnimations()
    }
}
