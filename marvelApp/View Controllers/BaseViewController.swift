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
    var pickedCatalog = ""
    var idForPickedEntry = ""
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComics" {
            let comicsVC = segue.destination as! ComicsViewController
            comicsVC.catalog = pickedCatalog
            comicsVC.id = idForPickedEntry
        }
    }
    
    func saveLoadedImage(at inadexPath: IndexPath, image: UIImage) {}
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

//MARK: - Data Manager Delegate
extension BaseViewController: DataManagerDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            delegate.tableView.reloadData()
            return
        }
        let indexPathsToReload = delegateClassDataModel.visibleIndexPathsToReload(indexPaths: newIndexPathsToReload, tableView: delegate.tableView)
        delegate.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

    func onFetchFailed(with reason: String) {
        HelperMethods.showFailureAlert(title: "Warning", message: reason, controller: self)
    }
}

//MARK: - SearchBar Delegate
extension BaseViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { }
}

//MARK: - UITableViewDataSourcePrefetching Delegate
extension BaseViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) { }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= delegateClassDataModel.dataCount
    }
}
