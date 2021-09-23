//
//  VoiceRoomMusicControlTableViewCell.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/31.
//

import UIKit
import Reusable

class VoiceRoomMusicControlTableViewCell: UITableViewCell, Reusable {
    private lazy var nameLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = ""
        return instance
    }()
    private lazy var volumeSlider: UISlider = {
        let instance = UISlider()
        instance.minimumValue = 0
        instance.maximumValue = 100
        instance.tintColor = UIColor(hexString: "#EF499A")
        instance.addTarget(self, action: #selector(handleSliderChanged(slider:)), for: .valueChanged)
        return instance
    }()
    private lazy var valueLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.text = ""
        return instance
    }()
    private lazy var separatorline: UIView = {
        let instance = UIView()
        instance.backgroundColor = .black.withAlphaComponent(0.1)
        return instance
    }()
    private lazy var openEarSwitch: UISwitch = {
        let instance = UISwitch()
        instance.onTintColor = UIColor(hexString: "#EF499A")
        instance.addTarget(self, action: #selector(handleSwitchChanged(switcher:)), for: .valueChanged)
        return instance
    }()
    private var type: MusicControlCellType!
    var sliderValueChanaged: ((Float, MusicControlCellType) -> Void)?
    var switchChanged:((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleSliderChanged(slider: UISlider) {
        valueLabel.text = "\(Int(slider.value))"
        sliderValueChanaged?(slider.value, type)
    }
    
    @objc private func handleSwitchChanged(switcher: UISwitch) {
        switchChanged?(switcher.isOn)
    }
    
    private func buildLayout() {
        backgroundColor = .clear
        contentView.addSubview(nameLabel)
        contentView.addSubview(volumeSlider)
        contentView.addSubview(valueLabel)
        contentView.addSubview(separatorline)
        contentView.addSubview(openEarSwitch)
        
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        volumeSlider.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(20)
            make.right.equalTo(valueLabel.snp.left).offset(-20)
            make.centerY.equalToSuperview()
        }
        
        separatorline.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(valueLabel)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        openEarSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(20)
        }
    }
    
    func updateCell(type: MusicControlCellType) {
        self.type = type
        nameLabel.text = type.name
        volumeSlider.isHidden = false
        valueLabel.isHidden = false
        openEarSwitch.isHidden = true
        switch type {
        case let .local(value):
            volumeSlider.value = value
            valueLabel.text = "\(Int(value))"
        case let .remote(value):
            volumeSlider.value = value
            valueLabel.text = "\(Int(value))"
        case let .micphone(value):
            volumeSlider.value = value
            valueLabel.text = "\(Int(value))"
        case let .ear(value):
            openEarSwitch.isOn = value
            volumeSlider.isHidden = true
            valueLabel.isHidden = true
            openEarSwitch.isHidden = false
        }
    }
}
