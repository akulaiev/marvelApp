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
    
    //MARK: - Data Manager Delegate
    override func saveLoadedImage(at inadexPath: IndexPath, image: UIImage) {
        if inadexPath.row < dataModel.characters.count {
            dataModel.characters[inadexPath.row].image = image
        }
    }
    
    //MARK: - SearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clear(tableView: tableView)
        searchQuery = searchBar.text ?? ""
        dataModel.fetchCharacterData(for: searchQuery)
    }
    
    //MARK: - UITableViewDataSourcePrefetching Delegate
    override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            dataModel.fetchCharacterData(for: searchQuery)
        }
    }
}
