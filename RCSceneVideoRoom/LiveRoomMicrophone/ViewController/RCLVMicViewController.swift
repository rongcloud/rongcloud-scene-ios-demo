//
//  LiveRoomMicrophoneViewController.swift
//  zero-football
//
//  Created by 叶孤城 on 2020/9/24.
//  Copyright © 2020 zerosportsai. All rights reserved.
//

import Foundation
import RCSceneService

protocol RCLVMicViewControllerDelegate: AnyObject {
    func didAcceptSeatRequest(_ user: VoiceRoomUser)
    func didRejectRequest(_ user: VoiceRoomUser)
    func didSendInvitation(_ user: VoiceRoomUser)
    func didSwitchMixType(_ type: RCLiveVideoMixType)
}

class RCLVMicViewController: UIViewController {
    
    weak var delegate: RCLVMicViewControllerDelegate?
    
    private lazy var containerView = UIView()
    
    private lazy var header: RCLVRSegmentControl = {
        let items: [RCLVRSegmentItem] = [
            RCLVRSegmentItem(title: "申请列表"),
            RCLVRSegmentItem(title: "邀请连麦"),
            RCLVRSegmentItem(title: "布局设置"),
        ]
        return RCLVRSegmentControl(items) { [weak self] in self?.move(index: $0)}
    }()
    private lazy var scrollView: UIScrollView = {
        let instance = UIScrollView()
        instance.showsVerticalScrollIndicator = false
        instance.showsHorizontalScrollIndicator = false
        instance.isPagingEnabled = true
        instance.delegate = self
        instance.contentInsetAdjustmentBehavior = .never
        return instance
    }()
    
    private let contentView = UIView()
    
    private lazy var controllers: [UIViewController] = {
        let request = RCLVRMicRequestViewController()
        let invite = RCLVRMicInviteViewController(seatIndex)
        let layout = RCLVRMicLayoutViewController()
       return [request, invite, layout]
    }()
    
    private let itemIndex: Int
    private let seatIndex: Int
    init(_ itemIndex: Int = 0, seatIndex: Int = -1) {
        self.itemIndex = itemIndex
        self.seatIndex = seatIndex
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        move(index: self.itemIndex)
        header.didMove(to: self.itemIndex)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        
        containerView.backgroundColor = UIColor(byteRed: 3, green: 6, blue: 47)
        view.addSubview(containerView)
        containerView.addSubview(header)
        containerView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(220.resize)
            make.left.right.bottom.equalToSuperview()
        }
        
        header.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(header.height())
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
    }
    
    func move(index: Int) {
        let offset = scrollView.scrollHOffset(index)
        scrollView.setContentOffset(offset, animated: true)
    }
}

extension RCLVMicViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header.offsetPercent(percent: scrollView.contentOffset.x/scrollView.bounds.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        header.didMove(to: scrollView.estimateHPage)
    }
}

extension UIScrollView {
    var estimateHPage: Int {
        return Int(contentOffset.x / bounds.width)
    }
    
    func scrollHOffset(_ page: Int) -> CGPoint {
        return CGPoint(x: bounds.width * CGFloat(page), y: 0)
    }
    
    func scrollHRect(_ page: Int) -> CGRect {
        let x = bounds.width * CGFloat(page)
        return CGRect(x: x, y: 0, width: bounds.width, height: bounds.height)
    }
}
