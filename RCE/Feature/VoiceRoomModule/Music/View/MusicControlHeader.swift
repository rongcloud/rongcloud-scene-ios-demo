//
//  MusicControlHeader.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import UIKit

class MusicControlHeader: UIView {
    private lazy var addMusicButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.music_header_add_selected_icon(), for: .selected)
        instance.setImage(R.image.music_header_add_unselected_icon(), for: .normal)
        instance.tag = 0
        instance.addTarget(self, action: #selector(handleButtonClick(sender:)), for: .touchUpInside)
        instance.isSelected = true
        return instance
    }()
    private lazy var musiclistButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.music_header_roomlist_unselected(), for: .normal)
        instance.setImage(R.image.music_header_roomlist_selected(), for: .selected)
        instance.tag = 1
        instance.addTarget(self, action: #selector(handleButtonClick(sender:)), for: .touchUpInside)
        return instance
    }()
    private lazy var musicControlButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.music_header_control_unselected_icon(), for: .normal)
        instance.setImage(R.image.music_header_control_selected_icon(), for: .selected)
        instance.tag = 2
        instance.addTarget(self, action: #selector(handleButtonClick(sender:)), for: .touchUpInside)
        return instance
    }()
    private lazy var effectControlButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.show_audio_effect_icon(), for: .normal)
        instance.setImage(R.image.hide_audio_effect_icon(), for: .selected)
        instance.tag = 3
        instance.addTarget(self, action: #selector(handleButtonClick(sender:)), for: .touchUpInside)
        return instance
    }()
    private lazy var stackView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [addMusicButton, musiclistButton, musicControlButton])
        instance.spacing = 15
        return instance
    }()
    var buttonClickCallback:((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        addSubview(effectControlButton)
        backgroundColor = UIColor.black.withAlphaComponent(0.17)
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.centerY.equalToSuperview()
        }
        
        effectControlButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(23)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleButtonClick(sender: UIButton) {
        switch sender.tag {
        case 0:
            musiclistButton.isSelected = false
            musicControlButton.isSelected = false
            addMusicButton.isSelected = true
        case 1:
            addMusicButton.isSelected = false
            musicControlButton.isSelected = false
            musiclistButton.isSelected = true
        case 2:
            addMusicButton.isSelected = false
            musiclistButton.isSelected = false
            musicControlButton.isSelected = true
        case 3:
            effectControlButton.isSelected.toggle()
        default:
            ()
        }
        buttonClickCallback?(sender.tag)
    }
    
    func select(index: Int) {
        switch index {
        case 0:
            musiclistButton.isSelected = false
            musicControlButton.isSelected = false
            addMusicButton.isSelected = true
        case 1:
            addMusicButton.isSelected = false
            musicControlButton.isSelected = false
            musiclistButton.isSelected = true
        case 2:
            addMusicButton.isSelected = false
            musiclistButton.isSelected = false
            musicControlButton.isSelected = true
        default:
            ()
        }
    }
}
