//
//  SettingTableViewCell.swift
//  RCE
//
//  Created by zangqilong on 2021/11/11.
//

import UIKit
import Reusable

class SettingTableViewCell: UITableViewCell, Reusable {

    
    func updateCell(item: SettingItem) {
        selectionStyle = .none
        textLabel?.font = .systemFont(ofSize: 16)
        textLabel?.textColor = UIColor(hexInt: 0x020037)
        imageView?.image = item.image
        textLabel?.text = item.title
        accessoryType = .disclosureIndicator
    }
}
