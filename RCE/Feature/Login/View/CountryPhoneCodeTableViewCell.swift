//
//  CountryPhoneCodeTableViewCell.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/12/16.
//

import UIKit
import Reusable


class CountryPhoneCodeTableViewCell: UITableViewCell, Reusable {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        textLabel?.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.centerY.equalToSuperview()
        }
        detailTextLabel?.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
