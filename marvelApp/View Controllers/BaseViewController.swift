//
//  BaseViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 29.12.2020.
//

import UIKit

protocol BaseViewControllerDelegate: class {
    var tableView: UITableView! { get set }
    var searchBar: UISearchBar! { get set }
    var cellIdentifier: String { get }
    var searchQuery: String { get }
}

class BaseViewController: UIViewController, UITableViewDelegate {
    var delegateClassDataModel: DataManager!
    weak var delegate: BaseViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func clear(tableView: UITableView) {
        guard let dataModel = delegateClassDataModel else { return }
        tableView.reloadData()
        dataModel.networkManager.requestOffset = 0
        dataModel.totalCount = 0
        dataModel.dataCount = 0
        dataModel.resetPaginationParams()
    }
}

// MARK: - Table view data source
extension BaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegateClassDataModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: delegate.cellIdentifier, for: indexPath)
        delegateClassDataModel.configureCell(cell)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
