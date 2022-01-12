//
//  PhoneCodeListProtocol.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/12/20.
//

import Foundation
import UIKit

class PhoneCodeListDataSource: NSObject, UITableViewDataSource {
    
    private let provider = CountryPhoneCodeProvider.shared

    func numberOfSections(in tableView: UITableView) -> Int {
        return provider.groupHeaderTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let region = provider.groupHeaderTitles[section]
        let datas = provider.countryGroupByRegion[region]
        return datas?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CountryPhoneCodeTableViewCell.self)
        let region = provider.groupHeaderTitles[indexPath.section]
        if let countryInfos = provider.countryGroupByRegion[region] {
            let country = countryInfos[indexPath.row]
            cell.textLabel?.text = country.cn
            cell.detailTextLabel?.text = country.code
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return provider.groupHeaderTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return provider.groupHeaderTitles
    }
}
