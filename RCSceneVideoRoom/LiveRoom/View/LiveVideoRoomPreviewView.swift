//
//  LiveVideoRoomPreviewView.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/7.
//

import UIKit

class LiveVideoRoomPreviewView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let previewView = RCLiveVideoEngine.shared().previewView()
        addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPreviewLayout(_ mixType: RCLiveVideoMixType) {
        let preview = RCLiveVideoEngine.shared().previewView()
        switch mixType {
        case .default, .oneToOne:
            preview.snp.remakeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(preview.snp.height).multipliedBy(9.0 / 16)
            }
        case .oneToSix:
            preview.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide).offset(98)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            }
        default:
            preview.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide).offset(98)
                make.height.equalTo(preview.snp.width)
            }
        }
    }
    
    func contentInsets() -> UIEdgeInsets {
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne: return .zero
        case .oneToSix: return UIEdgeInsets(top: view.safeAreaInsets.top + 98,
                                            left: 0,
                                            bottom: view.safeAreaInsets.bottom + 60,
                                            right: 0)
        default:
            let bottom = UIScreen.main.bounds.height - view.safeAreaInsets.top - UIScreen.main.bounds.width
            return UIEdgeInsets(top: view.safeAreaInsets.top + 98,
                                left: 0,
                                bottom: bottom,
                                right: 0)
        }
    }
}
