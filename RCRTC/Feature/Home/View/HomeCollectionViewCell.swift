//
//  HomeCollectionViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/21.
//

import Lottie
import Reusable
import RCSceneRoom
//MARK: - KRCAEJSONData
let KRCAEAudioRoomJsonData = "ae_audioRoom_data"
let KRCAEAudioCallJsonData = "ae_audioCall_data"
let KRCAEVideoCallJsonData = "ae_videoCall_data"
let KRCAELiveVideoJsonData = "ae_liveVideo_data"
let KRCAERadioRoomJsonData = "ae_radioRoom_data"
let KRCAEGameRoomJsonData = "ae_gameRoom_data"
let KRCAECommingSoonJsonData = "ae_comingsoon_data"

extension RCRoomType {
    var markImage: UIImage? {
        switch self {
        case .audioRoom:
            return R.image.new_home_icon_pro()
        case .liveVideo:
            return R.image.new_home_icon_pro()
        default:
            return nil
        }
    }
}

class HomeCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var markImageView = UIImageView()
    private var animationView : AnimationView?
    
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
        contentView.addSubview(markImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        
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
    
    func updateCell(item: RCRoomType) -> HomeCollectionViewCell {
        markImageView.image = item.markImage
        titleLabel.text = item.name
        descLabel.text = item.desc
        animationView = nil
        switch item {
        case .audioRoom:
            reagentAEAnimationView(KRCAEAudioRoomJsonData)
        case .audioCall:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.textColor = UIColor.init(hexString: "#CBFFDB", alpha: 0.8)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            reagentAEAnimationView(KRCAEAudioCallJsonData)
        case .videoCall:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.textColor = UIColor.init(hexString: "#99FFE7", alpha: 0.9)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            reagentAEAnimationView(KRCAEVideoCallJsonData)
        case .liveVideo:
            let fourAvtarImageView = UIImageView.init(image: R.image.four_avtar_placehoder())
            contentView.addSubview(fourAvtarImageView)
            fourAvtarImageView.snp.makeConstraints { make in
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
                make.leading.equalTo(fourAvtarImageView.snp.trailing).offset(6)
            }
            tipLab.snp.makeConstraints { make in
                make.width.equalTo(40)
                make.height.equalTo(14)
                make.leading.equalTo(onlineCountLab)
                make.top.equalTo(onlineCountLab.snp.bottom).offset(1)
            }
            
         reagentAEAnimationView(KRCAELiveVideoJsonData)
        case .radioRoom:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            reagentAEAnimationView(KRCAERadioRoomJsonData)
        case .gameRoom:
            reagentAEAnimationView(KRCAEGameRoomJsonData)
        case .musicKTV:
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            descLabel.textColor = UIColor.init(hexString: "#FFFFFF", alpha: 1)
            descLabel.font = .systemFont(ofSize: 10, weight: .regular)
            reagentAEAnimationView(KRCAECommingSoonJsonData)
        case .privateCall:
            break
        case .community:
            break
        }
        layoutIfNeeded()
        return self
    }
    
    func reagentAEAnimationView(_ someJSONFileName:String){
        // someJSONFileName 指的就是用 AE 导出的动画 本地 JSON文件名
        animationView = AnimationView(name: someJSONFileName)
        guard let animationView = animationView else { return  }
        contentView.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.sendSubviewToBack(animationView)
        animationView.play(fromProgress: nil, toProgress: 1, loopMode: .autoReverse) { (isFinished) in
            
        }
        animationView.backgroundBehavior = .pauseAndRestore
    }
    
}
