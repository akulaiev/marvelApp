//
//  AuthorsTableViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 23.12.2020.
//

import UIKit

class AuthorsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataModel: AuthorViewModel!
    var searchQuery = ""
    var pickedCatalog = ""
    var idForPickedEntry = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel = AuthorViewModel(delegate: self)
        dataModel.cellIdentifier = "searchAuthors"
        searchBar.delegate = self
        tableView.delegate = dataModel
        tableView.dataSource = dataModel
        tableView.prefetchDataSource = self
        self.hideKeyboardWhenTappedAround() 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComics" {
            let comicsVC = segue.destination as! ComicsViewController
            comicsVC.catalog = pickedCatalog
            comicsVC.id = idForPickedEntry
        }
    }
    
    func clear(tableView: UITableView) {
        dataModel.authors.removeAll()
        dataModel.clear(tableView: tableView)
    }
}

//MARK: - SearchBar Delegate
extension AuthorsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            clear(tableView: tableView)
            searchQuery = searchBar.text ?? ""
            dataModel.fetchAuthorData(for: searchQuery)
        }
        else {
            HelperMethods.showFailureAlert(title: "Warning", message: "Empty search input", controller: self)
        }
    }
}

//MARK: - Data Manager Delegate
extension AuthorsViewController: DataManagerDelegate {
    func selectedRow(in tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pickedCatalog = "creators"
        idForPickedEntry = "\(dataModel.authors[indexPath.row].id)"
        performSegue(withIdentifier: "toComics", sender: self)
    }
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        if dataModel.isLoadingCell(for: indexPath) == false {
            let dataEntry = dataModel.authors[indexPath.row]
            cell.textLabel?.text = dataEntry.fullName
            cell.imageView?.image = dataEntry.image
            if dataEntry.placeholderImage {
                dataModel.downloadImage(for: dataEntry.imageURL, for: cell, at: indexPath)
                dataEntry.placeholderImage = false
            }
        }
        return cell
    }
    
    func saveLoadedImage(at inadexPath: IndexPath, image: UIImage) {
        if inadexPath.row < dataModel.authors.count {
            dataModel.authors[inadexPath.row].image = image
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

//MARK: - UITableViewDataSourcePrefetching Delegate
extension AuthorsViewController: UITableViewDataSourcePrefetching {
   func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    if indexPaths.contains(where: dataModel.isLoadingCell) {
           dataModel.fetchAuthorData(for: searchQuery)
       }
   }
}
