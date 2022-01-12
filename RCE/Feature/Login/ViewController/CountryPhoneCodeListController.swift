//
//  CountryPhoneCodeListController.swift
//  RCE
//
//  Created by hanxiaoqing on 2021/12/16.
//

import UIKit
import Reusable
import ReactorKit
import RxCocoa

class CountryPhoneCodeListController: UIViewController {
    
    public var didSelectCountry: ((CountryInfo) -> Void)?
    
    private let searchController = UISearchController(searchResultsController: nil)

    private var searchDelay: TimeInterval = 0.5

    private var searchText: String?
    
    private(set) var dataSource = PhoneCodeListDataSource()
    
    private(set) var searchResultsDataSource = PhoneCodeSearchResultDataSource()

    let provider = CountryPhoneCodeProvider.shared
    
    private(set) lazy var backButton: UIButton = {
        let instance = UIButton()
        instance.setImage(R.image.back_indicator_image(), for: .normal)
        instance.addTarget(self, action: #selector(back), for: .touchUpInside)
        return instance
    }()
    
    private(set) lazy var phoneCodeTableView: UITableView = {
       let instance = UITableView(frame: .zero, style: .grouped)
        instance.register(cellType: CountryPhoneCodeTableViewCell.self)
        instance.rowHeight = 44
        instance.sectionHeaderHeight = 25
        instance.dataSource = dataSource
        instance.delegate = self;
       return instance
    }()

    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.definesPresentationContext = true
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "选择国家和地区"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        view.addSubview(phoneCodeTableView)
        phoneCodeTableView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaTop())
        }
        setupSearchController()
    }

    func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.tintColor = navigationController?.navigationBar.tintColor
        phoneCodeTableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if searchController.isActive { // self 无法 deinit 的问题
            searchController.isActive = false
        }
    }
    
    @objc private func back() {
        dismiss(animated: true, completion: nil)
    }
}


extension CountryPhoneCodeListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var infos: [CountryInfo]?
        
        if phoneCodeTableView.dataSource === dataSource {
            let region = provider.groupHeaderTitles[indexPath.section]
            infos = provider.countryGroupByRegion[region]
        } else if phoneCodeTableView.dataSource === searchResultsDataSource {
            infos = searchResultsDataSource.searchResults
        }
        
        if let infos = infos {
            let country = infos[indexPath.row]
            if let didSelectCountry = didSelectCountry {
                didSelectCountry(country)
            }
        }
        
    }
}

// MARK: - Search
extension CountryPhoneCodeListController {
    
    func show(_ controller: UIViewController) {
        let nav = UINavigationController(rootViewController: self)
        nav.modalTransitionStyle = .coverVertical
        nav.modalPresentationStyle = .overFullScreen
        controller.present(nav, animated: true, completion: nil)
    }
    
    func cancelPendingSearch() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }

    func performSearch(forText text: String, afterDelay delay: TimeInterval) {
        perform(#selector(performSearch(forText:)), with: text, afterDelay: delay)
    }

    @objc func performSearch(forText text: String) {
        if text.isEmpty {
            searchResultsDataSource.searchResults = []
        } else {
            searchResultsDataSource.searchResults = provider.filter(forKeyword: text)
        }
        if phoneCodeTableView.dataSource !== searchResultsDataSource {
            phoneCodeTableView.dataSource = searchResultsDataSource
        }
        phoneCodeTableView.reloadData()
    }
}

// MARK: - UISearchResultsUpdating
extension CountryPhoneCodeListController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else {
            cancelPendingSearch()
            searchText = nil
            return
        }

        guard let text = searchController.searchBar.text, searchText != text else {
            return
        }
        searchText = text
        
        cancelPendingSearch()
        
        if text.isEmpty {
            performSearch(forText: text)
        } else {
            performSearch(forText: text, afterDelay: searchDelay)
        }
    }
}

// MARK: - UISearchControllerDelegate
extension CountryPhoneCodeListController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        phoneCodeTableView.dataSource = dataSource
        phoneCodeTableView.reloadData()
    }
}


extension Reactive where Base == CountryPhoneCodeListController {
    var itemSelected: Observable<CountryInfo?> {
        return base.phoneCodeTableView.rx.itemSelected.map { indexPath in
            var infos: [CountryInfo]?
            
            if base.phoneCodeTableView.dataSource === base.dataSource {
                let region = base.provider.groupHeaderTitles[indexPath.section]
                infos = base.provider.countryGroupByRegion[region]
            } else if  base.phoneCodeTableView.dataSource === base.searchResultsDataSource {
                infos = base.searchResultsDataSource.searchResults
            }
            return infos?[indexPath.row]
        }
    }
}

public extension Reactive where Base: UIButton {
    var throttledTap: ControlEvent<Void> {
        return ControlEvent<Void>(events: tap
            .throttle(.milliseconds(2000), latest: false, scheduler: MainScheduler.instance))
    }
}
