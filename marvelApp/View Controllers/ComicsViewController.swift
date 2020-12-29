//
//  ComicsViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 29.12.2020.
//

import UIKit

//Extension for current VC, that doesn't need search bar
extension BaseViewControllerDelegate {
    var searchBar: UISearchBar! { get { return nil } set {} }
    var searchQuery: String {get { return "" } set {} }
    
}

class ComicsViewController: BaseViewController, BaseViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataModel: ComicsViewModel!
    var cellIdentifier = "comicsCell"
    var catalog = ""
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel = ComicsViewModel(delegate: self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        super.delegateClassDataModel = dataModel
        super.delegate = self
        dataModel.fetchComicsData(from: catalog, for: id)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configure(cell: cell, with: indexPath)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openImage" {
            let imageVC = segue.destination as! FullImageViewController
            if let cell = sender as? UITableViewCell {
                imageVC.imageToShow = cell.imageView?.image
            }
        }
    }
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) {
        dataModel.configureCell(cell)
        if !isLoadingCell(for: indexPath) {
            let dataEntry = dataModel.comics[indexPath.row]
            cell.textLabel?.text = dataEntry.title
            cell.detailTextLabel?.text = String(dataEntry.prices[0].price)
            cell.imageView?.image = dataEntry.image
            if dataEntry.placeholderImage {
                dataModel.downloadImage(for: dataEntry.imageURL, for: cell, at: indexPath)
                dataEntry.placeholderImage = false
            }
        }
    }
    
    override func clear(tableView: UITableView) {
        dataModel.comics.removeAll()
        super.clear(tableView: tableView)
    }
    
    //MARK: - Data Manager Delegate
    override func saveLoadedImage(at inadexPath: IndexPath, image: UIImage) {
        if inadexPath.row < dataModel.comics.count {
            dataModel.comics[inadexPath.row].image = image
        }
    }
    
    //MARK: - UITableViewDataSourcePrefetching Delegate
    override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            dataModel.fetchComicsData(from: catalog, for: id)
        }
    }
}
