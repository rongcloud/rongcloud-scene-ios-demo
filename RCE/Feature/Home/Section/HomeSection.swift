//
//  HomeSection.swift
//  RCE
//
//  Created by 叶孤城 on 2021/4/19.
//

import Foundation
import RxDataSources

struct HomeItem {
    let name: String
    let englishName: String
    let image: UIImage?
    let isEnable: Bool
}

struct HomeSection {
    var items: [HomeItem]
}

extension HomeSection: SectionModelType {
    typealias Item = HomeItem
    init(original: HomeSection, items: [HomeItem]) {
        self = original
        self.items = items
    }
}
