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

    private var dataModel: MarvelDataModel!
    private var searchQuery = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        dataModel = MarvelDataModel(delegate: self)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.totalCharactersCount ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchAuthors", for: indexPath)
        dataModel.configureCell(cell, withDataAt: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

//MARK: - Marvel Data Model Delegate
extension AuthorsViewController: MarvelDataModelDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.reloadData()
            return
        }
        let indexPathsToReload = dataModel.visibleIndexPathsToReload(indexPaths: newIndexPathsToReload, tableView: tableView)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

    func onFetchFailed(with reason: String) {
        HelperMethods.showFailureAlert(title: "Warning", message: reason, controller: self)
    }
}

//MARK: - SearcBar Delegate
extension AuthorsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dataModel.clear(tableView: tableView)
        searchQuery = searchBar.text ?? ""
        dataModel.search(for: Request.searchAuthors(searchQuery))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            dataModel.clear(tableView: tableView)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dataModel.clear(tableView: tableView)
    }
}

extension AuthorsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: dataModel.isLoadingCell) {
            dataModel.search(for: Request.searchAuthors(searchQuery))
        }
    }
}
