//
//  CharactersTableViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 23.12.2020.
//

import UIKit

class CharactersViewController: BaseViewController, BaseViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataModel: CharacterViewModel!
    var cellIdentifier = "searchCharacters"
    var searchQuery = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel = CharacterViewModel(delegate: self)
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        super.delegateClassDataModel = dataModel
        super.delegate = self
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configure(cell: cell, with: indexPath)
        return cell
    }
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) {
        dataModel.configureCell(cell)
        if !isLoadingCell(for: indexPath) {
            let dataEntry = dataModel.characters[indexPath.row]
            cell.textLabel?.text = dataEntry.name
            cell.imageView?.image = dataEntry.image
            if dataEntry.placeholderImage {
                dataModel.downloadImage(for: dataEntry.imageURL, for: cell, at: indexPath)
                dataEntry.placeholderImage = false
            }
        }
    }
    
    override func clear(tableView: UITableView) {
        dataModel.characters.removeAll()
        super.clear(tableView: tableView)
    }
}

//MARK: - Data Manager Delegate
extension CharactersViewController: DataManagerDelegate {
    func saveLoadedImage(at inadexPath: IndexPath, image: UIImage) {
        if inadexPath.row < dataModel.characters.count {
            dataModel.characters[inadexPath.row].image = image
        }
    }

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

//MARK: - SearchBar Delegate
extension CharactersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clear(tableView: tableView)
        searchQuery = searchBar.text ?? ""
        dataModel.fetchCharacterData(for: searchQuery)
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

extension CharactersViewController: UITableViewDataSourcePrefetching {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= dataModel.dataCount
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            dataModel.fetchCharacterData(for: searchQuery)
        }
    }
}



//class CharactersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var searchBar: UISearchBar!
//
//    var dataModel: CharacterViewModel!
//    var cellIdentifier = "searchCharacters"
//    var searchQuery = ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        dataModel = CharacterViewModel(delegate: self)
//        searchBar.delegate = self
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.prefetchDataSource = self
//    }
//
//    // MARK: - Table view data source
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataModel.totalCount
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        configure(cell: cell, with: indexPath)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//
//    func configure(cell: UITableViewCell, with indexPath: IndexPath) {
//        dataModel.configureCell(cell)
//        if !isLoadingCell(for: indexPath) {
//            let dataEntry = dataModel.characters[indexPath.row]
//            cell.textLabel?.text = dataEntry.name
//            cell.imageView?.image = dataEntry.image
//            if dataEntry.placeholderImage {
//                dataModel.downloadImage(for: dataEntry.imageURL, for: cell, at: indexPath)
//                dataEntry.placeholderImage = false
//            }
//        }
//    }
//
//    func clear(tableView: UITableView) {
//        guard let dataModel = dataModel else { return }
//        dataModel.characters.removeAll()
//        tableView.reloadData()
//        dataModel.networkManager.requestOffset = 0
//        dataModel.resetPaginationParams()
//    }
//}
//
////MARK: - Data Manager Delegate
//extension CharactersViewController: DataManagerDelegate {
//    func saveLoadedImage(at inadexPath: IndexPath, image: UIImage) {
//        dataModel.characters[inadexPath.row].image = image
//    }
//
//    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
//        guard let newIndexPathsToReload = newIndexPathsToReload else {
//            tableView.reloadData()
//            return
//        }
//        let indexPathsToReload = dataModel.visibleIndexPathsToReload(indexPaths: newIndexPathsToReload, tableView: tableView)
//        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
//    }
//
//    func onFetchFailed(with reason: String) {
//        HelperMethods.showFailureAlert(title: "Warning", message: reason, controller: self)
//    }
//}
//
////MARK: - SearchBar Delegate
//extension CharactersViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        clear(tableView: tableView)
//        searchQuery = searchBar.text ?? ""
//        dataModel.fetchCharacterData(for: searchQuery)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText == "" {
//            clear(tableView: tableView)
//        }
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        clear(tableView: tableView)
//    }
//}
//
//extension CharactersViewController: UITableViewDataSourcePrefetching {
//    func isLoadingCell(for indexPath: IndexPath) -> Bool {
//        return indexPath.row >= dataModel.dataCount
//    }
//
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        if indexPaths.contains(where: isLoadingCell) {
//            dataModel.fetchCharacterData(for: searchQuery)
//        }
//    }
//}
