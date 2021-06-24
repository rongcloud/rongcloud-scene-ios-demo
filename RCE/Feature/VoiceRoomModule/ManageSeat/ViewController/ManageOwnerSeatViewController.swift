//
//  OwnerSeatPopViewController.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/11.
//

import UIKit

protocol ManageOwnerSeatProtocol: AnyObject {
    func leaveSeatDidClick()
    func muteSeatDidClick(isMute: Bool)
}

class ManageOwnerSeatViewController: UIViewController {
    private let userId: String
    private let isMute: Bool
    weak var delegate: ManageOwnerSeatProtocol?
    private lazy var popView: OwnerSeatPopView = {
        return OwnerSeatPopView {
            [weak self] in
            self?.delegate?.leaveSeatDidClick()
            self?.dismiss(animated: true, completion: nil)
        } muteSeatCallback: {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.muteSeatDidClick(isMute: !self.isMute)
            self.dismiss(animated: true, completion: nil)
        }
    }()
    private lazy var tapGestureView = RCTapGestureView(self)
    
    init(userId: String, isMute: Bool, delegate: ManageOwnerSeatProtocol) {
        self.delegate = delegate
        self.userId = userId
        self.isMute = isMute
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tapGestureView)
        view.addSubview(popView)
        tapGestureView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(popView.snp.top).offset(-20)
        }
        popView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
        }
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { [weak self] user in
            self?.popView.updateView(user: user)
        }
        if isMute {
            popView.muteButton.setTitle("打开麦克风", for: .normal)
        } else {
            popView.muteButton.setTitle("关闭麦克风", for: .normal)
        }
    }
}
