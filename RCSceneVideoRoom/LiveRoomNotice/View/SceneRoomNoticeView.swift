//
//  RoomNoticeView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/2.
//

import UIKit
import RCSceneRoomSetting

class SceneRoomMarkView: UIView {
    private(set) lazy var iconImageView: UIImageView = {
        let instance = UIImageView(image: R.image.room_notice_icon())
        instance.contentMode = .scaleAspectFit
        return instance
    }()
    private(set) lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.text = "公告"
        instance.font = .systemFont(ofSize: 12.resize)
        instance.textColor = UIColor.white.withAlphaComponent(0.8)
        return instance
    }()
    
    var content: String {
        return nameLabel.text ?? ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
    
    private func buildLayout() {
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        clipsToBounds = true
        
        addSubview(iconImageView)
        addSubview(nameLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7.resize)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(4.resize)
            make.right.equalToSuperview().inset(7.resize)
            make.top.bottom.equalToSuperview().inset(4.resize)
        }
    }
    
    func update(_ content: String) {
        nameLabel.text = content
    }
}

class SceneRoomNoticeView: SceneRoomMarkView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconImageView.image = R.image.room_notice_icon()
        nameLabel.text = "公告"
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTap() {
        videoRouter.trigger(.notice(modify: false, notice: "", delegate: self))
    }
}

extension SceneRoomNoticeView: RCSceneRoomSettingProtocol {
    func eventDidTrigger(_ item: Item, extra: String?) {
        
    }
}
