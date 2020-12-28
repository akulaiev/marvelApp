//
//  AuthorsTableViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 23.12.2020.
//

import UIKit

class AuthorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataModel: AuthorViewModel?
    var cellIdentifier = "searchAuthors"
    var searchQuery = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        dataModel = AuthorViewModel(delegate: self)
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.authors?.paginationData.total ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configure(cell: cell, with: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) {
        if let dataModel = dataModel {
            dataModel.configureCell(cell)
            if !isLoadingCell(for: indexPath) {
                if let dataEntry = dataModel.authors?.result[indexPath.row] {
                    cell.textLabel?.text = dataEntry.fullName
                    cell.imageView?.image = dataEntry.image
                    if dataEntry.placeholderImage {
                        dataModel.downloadImage(for: dataEntry.imageURLComponents, for: cell)
                        dataEntry.placeholderImage = false
                    }
                    else {
                        dataEntry.image = cell.imageView?.image
                    }
                }
            }
        }
    }
    
    func clear(tableView: UITableView) {
        guard let dataModel = dataModel else { return }
        dataModel.authors?.result.removeAll()
        tableView.reloadData()
        dataModel.networkManager.requestOffset = 0
        dataModel.authors?.paginationData.reset()
    }
}

//MARK: - Data Manager Delegate
extension AuthorsViewController: DataManagerDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.reloadData()
            return
        }
        if let dataModel = dataModel {
            let indexPathsToReload = dataModel.visibleIndexPathsToReload(indexPaths: newIndexPathsToReload, tableView: tableView)
            tableView.reloadRows(at: indexPathsToReload, with: .automatic)
        }
    }

    func onFetchFailed(with reason: String) {
        HelperMethods.showFailureAlert(title: "Warning", message: reason, controller: self)
    }
}

//MARK: - SearchBar Delegate
extension AuthorsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clear(tableView: tableView)
        searchQuery = searchBar.text ?? ""
        dataModel?.fetchAuthorData(for: searchQuery)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            clear(tableView: tableView)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clear(tableView: tableView)
    }
}

extension AuthorsViewController: UITableViewDataSourcePrefetching {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= dataModel?.authors.paginationData.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let dataModel = dataModel, indexPaths.contains(where: isLoadingCell) {
            dataModel.fetchAuthorData(for: searchQuery)
        }
    }
}
