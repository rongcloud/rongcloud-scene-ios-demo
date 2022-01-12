//
//  CountryPhoneCodeProvider.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/12/20.
//

import Foundation

public class CountryPhoneCodeProvider {
    
    public private(set) static var shared = CountryPhoneCodeProvider()
    
    private var countryInfoList: [CountryInfo] = []

    public var countryGroupByRegion: [String: [CountryInfo]] = [:]
    
    public var groupHeaderTitles: [String] = []
    
    private var countryInfoByRegion: [String: CountryInfo] = [:]
    
    private var countryInfoByCode: [String: [CountryInfo]] = [:]
    
    public init() {
        let resourceURL = Bundle.main.url(forResource:"countrycode", withExtension:"json")
        guard let resourceURL = resourceURL, let data = try? Data(contentsOf: resourceURL) else { return }
        do {
            countryInfoList = try JSONDecoder().decode([CountryInfo].self, from: data)
        } catch {
            print("error:\(error)")
        }
        countryGroupByRegion = Dictionary(grouping: countryInfoList) { String($0.en.first!)}
        .mapValues { $0.sorted { $0.en.localizedStandardCompare($1.en) == .orderedAscending }}
        groupHeaderTitles = countryGroupByRegion.keys.sorted()
        countryInfoByRegion = Dictionary(uniqueKeysWithValues: countryInfoList.map { ($0.cn, $0) })
        countryInfoByCode = Dictionary(grouping: countryInfoList) { $0.code }
    }
}

extension CountryPhoneCodeProvider {
    
    enum RegExpType: String {
        case number = "^\\+?\\d+$"
        case letter = "^[a-zA-Z]+$"
        case chinese = "^[\\u4e00-\\u9fa5]+$"
    }

    func evaluateText(_ text: String, with regExp: RegExpType) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regExp.rawValue).evaluate(with: text)
    }

    func filter(forKeyword keyword: String) -> [CountryInfo] {
        let searchKey = String(keyword.trimmingCharacters(in: .whitespaces).split(separator: " ").first!)
       
        if evaluateText(searchKey, with: .number) {
            return countryInfoList.filter { $0.code.contains(searchKey) }
        }
        if evaluateText(searchKey, with: .letter) {
            return countryInfoList.filter { $0.en.contains(searchKey) }
        }
        if evaluateText(searchKey, with: .chinese) {
            return countryInfoList.filter { $0.cn.contains(searchKey) }
        }
        return [CountryInfo]()
    }

    func filter(forCode code: String) -> [CountryInfo]? {
        let code = code.hasPrefix("+") ? code : "+" + code
        return countryInfoByCode[code]
    }

    func filter(forRegion region: String) -> CountryInfo? {
        return countryInfoByRegion[region]
    }
}
