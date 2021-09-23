//
//  VoiceRoomMusicControlViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/24.
//

import RxSwift
import RxCocoa
import RxDataSources

class VoiceRoomMusicControlViewController: UIViewController {
    private(set) var disposeBag = DisposeBag()
    
    private let roomId: String
    private lazy var scrollView: UIScrollView = {
        let instance = UIScrollView()
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.isPagingEnabled = true
        instance.delegate = self
        instance.contentInsetAdjustmentBehavior = .never
        return instance
    }()
    private lazy var header: MusicControlHeader = {
        let instance = MusicControlHeader()
        instance.buttonClickCallback = {
           [weak self] tag in
            if tag < 3 {
                self?.move(index: tag)
            } else {
                self?.soundEffectView.isHidden.toggle()
            }
        }
        return instance
    }()
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private let contentView = UIView()
    private lazy var controllers: [UIViewController] = {
        let musiclistVC = VoiceRoomMusicListViewController(roomId: self.roomId)
        let userAddedVC = VoiceRoomUserAddedMusicViewController(roomId: self.roomId, appendCallback: {
            [weak self] in
            self?.move(index: 1)
            self?.header.select(index: 1)
        })
        let musicControlVC = VoiceRoomMusicMixerViewController()
       return [userAddedVC, musiclistVC, musicControlVC]
    }()
    private lazy var separatorline: UIView = {
        let instance = UIView()
        instance.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        return instance
    }()
    
    private(set) lazy var soundEffectView = VoiceRoomSoundEffectView()
    
    init(roomId: String) {
        self.roomId = roomId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        
        soundEffectView.isHidden = true
        soundEffectView.rx.soundEffect
            .subscribe(onNext: { [weak self] item in
                self?.didSoundEffectClicked(item)
            })
            .disposed(by: disposeBag)
        RCRTCEngine.sharedInstance().audioEffectManager.setEffectsVolume(20)
    }
    
    private func buildLayout() {
        view.addSubview(blurView)
        view.addSubview(header)
        view.addSubview(scrollView)
        view.addSubview(soundEffectView)
        view.addSubview(separatorline)
        
        scrollView.addSubview(contentView)
        header.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(300.resize)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(header.snp.bottom)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom)
            make.bottom.equalTo(view)
            make.left.right.equalToSuperview()
        }
        
        controllers.enumerated().forEach { (index, vc) in
            addChild(vc)
            contentView.addSubview(vc.view)
            vc.view.snp.makeConstraints { (make) in
                if index == 0 {
                    make.top.bottom.left.equalToSuperview()
                    make.width.equalTo(view)
                } else if index == controllers.count - 1 {
                    make.top.bottom.right.equalToSuperview()
                    make.left.equalTo(controllers[index - 1].view.snp.right)
                    make.width.equalTo(view)
                } else {
                    make.top.bottom.equalToSuperview()
                    make.left.equalTo(controllers[index - 1].view.snp.right)
                    make.width.equalTo(view)
                }
            }
            vc.didMove(toParent: self)
        }
        
        blurView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(header)
        }
        
        soundEffectView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5.resize)
            make.bottom.equalTo(blurView.snp.top).offset(-5.resize)
            make.height.equalTo(54.resize)
        }
        
        separatorline.snp.makeConstraints { make in
            make.top.equalTo(header)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func move(index: Int) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * view.bounds.width, y: 0), animated: true)
    }
    
    private func didSoundEffectClicked(_ item: AudioEffect) {
        RCRTCEngine.sharedInstance().audioEffectManager.stopAllEffects()
        RCRTCEngine.sharedInstance().audioEffectManager.playEffect(item.id, filePath: item.filePath, loopCount: 1, publish: true)
    }
}

extension VoiceRoomMusicControlViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.bounds.width
        header.select(index: Int(index))
    }
}
