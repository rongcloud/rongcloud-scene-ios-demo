//
//  PhoneCodeSearchResultDataSource.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/12/20.
//

import Foundation

class PhoneCodeSearchResultDataSource: NSObject, UITableViewDataSource {
    var searchResults = [CountryInfo]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CountryPhoneCodeTableViewCell.self)
        let country = searchResults[indexPath.row]
        cell.textLabel?.text = country.cn
        cell.detailTextLabel?.text = country.code
        return cell
    }
}
