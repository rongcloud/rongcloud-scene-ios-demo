//
//  PromotionItemsView.swift
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

import UIKit

enum PromotionItem {
    case scheme
    case demo
    case online
    case about
    
    var title: String {
        switch self {
        case .scheme: return "套餐方案"
        case .demo: return "Demo 下载"
        case .online: return "在线客服"
        case .about: return "关于我们"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .scheme: return R.image.promotion_item_scheme()
        case .demo: return R.image.promotion_item_demo()
        case .online: return R.image.promotion_item_online()
        case .about: return R.image.promotion_item_about()
        }
    }
    
    var color: UIColor {
        switch self {
        case .scheme: return UIColor(byteRed: 255, green: 247, blue: 249)
        case .demo: return UIColor(byteRed: 245, green: 244, blue: 255)
        case .online: return UIColor(byteRed: 243, green: 254, blue: 253)
        case .about: return UIColor(byteRed: 247, green: 250, blue: 255)
        }
    }
    
    var path: String {
        switch self {
        case .scheme: return "https://www.rongcloud.cn/activity/rtc20"
        case .demo: return "https://m.rongcloud.cn/downloads/demo"
        case .online: return "https://m.rongcloud.cn/cs"
        case .about: return "https://m.rongcloud.cn/about"
        }
    }
    
    var umengEvent: UMengEvent {
        switch self {
        case .scheme: return .SettingPackage
        case .about: return .SettingAboutUs
        case .demo: return .SettingDemoDownload
        case .online: return .SettingCS
        }
    }
}

final class PromotionItemView: UIView {
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = UIColor(byteRed: 2, green: 0, blue: 55)
        instance.font = UIFont.systemFont(ofSize: 16.resize, weight: .medium)
        return instance
    }()
    private lazy var imageView = UIImageView()
    private let type: PromotionItem
    private let onClicked: (PromotionItem) -> Void
    init(_ type: PromotionItem, onClicked: @escaping (PromotionItem) -> Void) {
        self.type = type
        self.onClicked = onClicked
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(imageView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.resize)
            make.centerY.equalTo(snp.top).offset(25.resize)
        }
        
        let size = type.icon?.size ?? CGSize(width: 60.resize, height: 60.resize)
        imageView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(10.resize)
            make.size.equalTo(CGSize(width: size.width.resize, height: size.height.resize))
        }
        
        titleLabel.text = type.title
        imageView.image = type.icon
        backgroundColor = type.color
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTap() {
        onClicked(type)
        type.umengEvent.trigger()
    }
}

final class PromotionItemsView: UIView {

    private lazy var schemeView = PromotionItemView(.scheme, onClicked: onItemClicked)
    private lazy var demoView = PromotionItemView(.demo, onClicked: onItemClicked)
    private lazy var onlineView = PromotionItemView(.online, onClicked: onItemClicked)
    private lazy var aboutView = PromotionItemView(.about, onClicked: onItemClicked)
    
    private let onItemClicked: (PromotionItem) -> Void

    init(_ itemClicked: @escaping (PromotionItem) -> Void) {
        self.onItemClicked = itemClicked
        super.init(frame: .zero)
        
        addSubview(schemeView)
        addSubview(demoView)
        addSubview(onlineView)
        addSubview(aboutView)
        
        let itemSize = CGSize(width: 156.resize, height: 100.resize)
        
        schemeView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.size.equalTo(itemSize)
        }
        
        demoView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(itemSize)
        }
        
        onlineView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.size.equalTo(itemSize)
        }
        
        aboutView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.size.equalTo(itemSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
