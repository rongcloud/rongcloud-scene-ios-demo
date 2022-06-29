//
//  HomeCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import UIKit
import Reusable

import Lottie

import RCSceneVoiceRoom

extension RCScene {
    var image: UIImage? {
        switch self {
        case .audioRoom: //语音房
            return nil //UIImage.init(named: "ae_audioRoom_img_4") //R.image.home_icon_voice_room()
        case .videoCall: //视频通话
            return nil //R.image.home_icon_video_call()
        case .audioCall: //语音通话
            return nil // R.image.home_icon_voice_call()
        case .radioRoom: //语音电台
            return  nil //R.image.home_icon_radio_room()
        case .liveVideo: //视频直播
            return nil //UIImage.init(named: "Frame_288__2_") //R.image.home_icon_video_room()
        case .gameRoom: // 游戏房
            return  nil //R.image.home_gameRoomBg()
        case .musicKTV: // KTV  comming Soon
            return nil //UIImage.init(named: "home_coming_soonBg")//R.image.home_coming_soonBg()
        case .community:
            return nil
        case .privateCall:
            return nil
    // default:
    //     return R.image.home_icon_voice_room()
        }
    }
    
    var markImage: UIImage? {
        switch self {
        case .audioRoom:
            return R.image.new_home_icon_pro() //R.image.home_icon_pro()
        case .liveVideo:
            return R.image.new_home_icon_pro() //R.image.home_icon_new()
        default:
            return nil
        }
    }
    
    var enabled: Bool {
        return true
    }
}

class HomeCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var itemImageView = UIImageView()
    private lazy var markImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 20, weight: .medium)
        instance.textColor = .white
        return instance
    }()
    private lazy var descLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14, weight: .regular)
        instance.textColor = UIColor.init(hexString: "#FFFFFF", alpha: 0.8)
        instance.numberOfLines = 0
        return instance
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(itemImageView)
        contentView.addSubview(markImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        
        itemImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        markImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-12)
            make.right.equalToSuperview().offset(14)
            make.width.height.equalTo(67.resize)
            make.height.equalTo(73.resize)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16.resize)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(item: RCScene) -> HomeCollectionViewCell {
        itemImageView.image = item.image
        markImageView.image = item.markImage
        titleLabel.text = item.name
        descLabel.text = item.desc
 
        switch item {
        case .audioRoom:
            addAEAnimationView("ae_audioRoom_data")
            print(item)
        case .audioCall:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.textColor = UIColor.init(hexString: "#CBFFDB", alpha: 0.8)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            addAEAnimationView("ae_audioCall_data")
            print(item)
        case .videoCall:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.textColor = UIColor.init(hexString: "#99FFE7", alpha: 0.9)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            addAEAnimationView("ae_videoCall_data")
            print(item)
        case .liveVideo:

            let four_avtarImagV = UIImageView.init(image: R.image.four_avtar_placehoder())
            contentView.addSubview(four_avtarImagV)
            four_avtarImagV.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(11)
                make.bottom.equalToSuperview().offset(-19)
                make.width.height.equalTo(100.resize)
                make.height.equalTo(34.resize)
            }
            
            let onlineCountLab: UILabel = {
               let instance = UILabel()
               instance.font = .systemFont(ofSize: 14, weight: .medium)
               instance.textColor = .white
               instance.text = "2790人" //暂无接口,后期加入接口,再修改
               instance.tag = 4086 + 1
               instance.numberOfLines = 0
               return instance
            }()
            
            let tipLab: UILabel = {
                let instance = UILabel()
                instance.font = .systemFont(ofSize: 10, weight: .medium)
                instance.textColor = .white
                instance.text = "在直播" //暂无接口,后期加入接口,再修改
                return instance
            }()
            
            contentView.addSubview(onlineCountLab)
            contentView.addSubview(tipLab)
            
            onlineCountLab.snp.makeConstraints { make in
                make.height.equalTo(19)
                make.width.equalTo(67)
                make.bottom.equalToSuperview().offset(-36)
                make.leading.equalTo(four_avtarImagV.snp.trailing).offset(6)
            }
            tipLab.snp.makeConstraints { make in
                make.width.equalTo(40)
                make.height.equalTo(14)
                make.leading.equalTo(onlineCountLab)
                make.top.equalTo(onlineCountLab.snp.bottom).offset(1)
            }
            
            addAEAnimationView("ae_liveVideo_data")
         
            print(item)
        case .radioRoom:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            addAEAnimationView("ae_radioRoom_data")
            print(item)
        case .gameRoom:
            addAEAnimationView("ae_gameRoom_data")
            print(item)

        case .musicKTV:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.textColor = UIColor.init(hexString: "#FFFFFF", alpha: 1)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            addAEAnimationView("ae_comingsoon_data")
            print(":zap:musicKTV-> \(item)")
        case .privateCall:
            print(item)
        case .community:
            print(item)
        }
//        if item == .audioRoom {
//            titleLabel.snp.remakeConstraints { make in
//                make.top.equalToSuperview().offset(40.resize)
//                make.left.equalToSuperview().offset(16.resize)
//            }
//
//            descLabel.snp.remakeConstraints { make in
//                make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
//                make.left.equalTo(titleLabel)
//                make.width.equalToSuperview().multipliedBy(0.5)
//            }
//        } else {
//            titleLabel.snp.remakeConstraints { make in
//                make.top.left.equalToSuperview().offset(16.resize)
//            }
//
//            descLabel.snp.remakeConstraints { make in
//                make.top.equalTo(titleLabel.snp.bottom).offset(4.resize)
//                make.left.equalTo(titleLabel)
//                make.right.equalToSuperview().inset(16)
//            }
//        }
        layoutIfNeeded()
        return self
    }
    
    func addAEAnimationView(_ someJSONFileName:String) {
        // someJSONFileName 指的就是用 AE 导出的动画 本地 JSON文件名
        let animationView = AnimationView(name: someJSONFileName)
            
        itemImageView.addSubview(animationView)
//            contentView.sendSubviewToBack(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        animationView.play(fromProgress: nil, toProgress: 1, loopMode: .autoReverse) { (isFinished) in
            // 播放完成后的回调闭包
//                animationView.play()
            
        }
        // 设置当前进度
//            animationView.currentProgress = 0.5
            
//            animationView.play { (isFinished) in
//                // 动画执行完成后的回调
//            }
        
        // 循环模式
//            animationView.loopMode = .autoReverse
        // 到后台的行为模式
        animationView.backgroundBehavior = .pauseAndRestore
//            animationView.animationSpeed = 1.5
    }
}
