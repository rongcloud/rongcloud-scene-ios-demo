//
//  ScrollParentViewController.swift
//  zero-football
//
//  Created by 叶孤城 on 2020/9/24.
//  Copyright © 2020 zerosportsai. All rights reserved.
//

import UIKit

protocol HandleRequestSeatProtocol: AnyObject {
    func acceptUserRequestSeat(userId: String)
    func inviteUserToSeat(userId: String)
}

class RequestOrInviteViewController: UIViewController {
    private weak var delegate: HandleRequestSeatProtocol?
    private let roomId: String
    private let showPage: Int
    private lazy var header: VoiceRoomScrollHeader = {
       return VoiceRoomScrollHeader(titleClick: { [weak self] index in
        if index == 0 {
            self?.scrollView.setContentOffset(.zero, animated: true)
        } else {
            self?.scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width, y: 0), animated: true)
        }
    })
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
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let instance = UIVisualEffectView(effect: effect)
        return instance
    }()
    private let contentView = UIView()
    private lazy var controllers: [UIViewController] = {
        let requestVC = RequestSeatViewController { [weak self] userId in
            self?.delegate?.acceptUserRequestSeat(userId: userId)
            self?.dismiss(animated: true, completion: nil)
        }
        let inviteVC = InviteSeatViewController(roomId: roomId, onSeatUserList: onSeatUserIds) {[weak self] userId in
            self?.delegate?.inviteUserToSeat(userId: userId)
            self?.dismiss(animated: true, completion: nil)
        }
       return [requestVC, inviteVC]
    }()
    private let onSeatUserIds: [String]
    
    init(roomId: String, delegate: HandleRequestSeatProtocol, showPage: Int, onSeatUserIds: [String]) {
        self.delegate = delegate
        self.roomId = roomId
        self.showPage = showPage
        self.onSeatUserIds = onSeatUserIds
        super.init(nibName: nil, bundle: nil)
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
        move(index: showPage)
        header.didMove(to: showPage)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.roundCorners(corners: [.topLeft, .topRight], radius: 22)
    }
    
    private func buildLayout() {
        enableClickingDismiss()
        view.addSubview(blurView)
        view.addSubview(header)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        header.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(220.resize)
            make.left.right.equalToSuperview()
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
        
        blurView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(header)
        }
    }
    
    func move(index: Int) {
        if index == 0 {
            scrollView.setContentOffset(.zero, animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width, y: 0), animated: true)
        }
    }
}

extension RequestOrInviteViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header.offsetPercent(percent: scrollView.contentOffset.x/scrollView.bounds.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= scrollView.bounds.size.width {
            header.didMove(to: 1)
        } else {
            header.didMove(to: 0)
        }
    }
}
