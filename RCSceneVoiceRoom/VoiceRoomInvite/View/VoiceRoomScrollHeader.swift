//
//  VoiceRoomScrollHeader.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/10.
//

import UIKit

typealias TitleDidClick = (Int) -> Void
class VoiceRoomScrollHeader: UIView {
    private lazy var requestLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = R.color.hexEF499A()
        instance.text = "申请列表"
        instance.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRequestClick))
        instance.addGestureRecognizer(tap)
        return instance
    }()
    private lazy var inviteLabel: UILabel = {
        let instance = UILabel()
        instance.text = "邀请连麦"
        instance.font = .systemFont(ofSize: 17, weight: .medium)
        instance.textColor = UIColor.white.withAlphaComponent(0.5)
        instance.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleInviteClick))
        instance.addGestureRecognizer(tap)
        return instance
    }()
    private lazy var lineView: UIView = {
        let instance = UIView()
        instance.backgroundColor = R.color.hexEF499A()
        instance.layer.cornerRadius = 2
        instance.clipsToBounds = true
        return instance
    }()
    private var clickCallback: TitleDidClick
    
    init(titleClick: @escaping TitleDidClick) {
        self.clickCallback = titleClick
        super.init(frame: .zero)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleRequestClick() {
        move(index: 0)
        self.clickCallback(0)
    }
    
    @objc func handleInviteClick() {
        move(index: 1)
        self.clickCallback(1)
    }
    
    private func buildLayout() {
        addSubview(requestLabel)
        addSubview(inviteLabel)
        addSubview(lineView)
        
        requestLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(60.resize)
        }
        
        inviteLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(60.resize)
        }
        
        lineView.snp.remakeConstraints {
            $0.size.equalTo(CGSize(width: 27, height: 3))
            $0.centerX.equalTo(requestLabel)
            $0.top.equalTo(requestLabel.snp.bottom).offset(2)
        }
    }
    
    private func move(index: Int) {
        if index == 0 {
            lineView.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 27, height: 3))
                $0.centerX.equalTo(requestLabel)
                $0.top.equalTo(requestLabel.snp.bottom).offset(2)
            }
            requestLabel.textColor = R.color.hexEF499A()
            inviteLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        } else {
            lineView.snp.remakeConstraints {
                $0.size.equalTo(CGSize(width: 27, height: 3))
                $0.centerX.equalTo(inviteLabel)
                $0.top.equalTo(inviteLabel.snp.bottom).offset(2)
            }
            inviteLabel.textColor = R.color.hexEF499A()
            requestLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

protocol ScrollableHeaderProtocol where Self: UIView {
    func didMove(to index: Int)
    func height() -> CGFloat
    func offsetPercent(percent: CGFloat)
}

extension VoiceRoomScrollHeader: ScrollableHeaderProtocol {
    func didMove(to index: Int) {
        move(index: index)
    }
    
    func height() -> CGFloat {
        return 63
    }
    
    func offsetPercent(percent: CGFloat) {
        
    }
}
