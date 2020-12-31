//
//  ComicsViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 29.12.2020.
//

import UIKit

class ComicsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataModel: ComicsViewModel!
    var catalog = ""
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel = ComicsViewModel(delegate: self)
        dataModel.cellIdentifier = "comicsCell"
        tableView.delegate = dataModel
        tableView.dataSource = dataModel
        tableView.prefetchDataSource = self
        dataModel.fetchComicsData(from: catalog, for: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openImage" {
            let imageVC = segue.destination as! FullImageViewController
            if let cell = sender as? UITableViewCell {
                imageVC.imageToShow = cell.imageView?.image
            }
        }
    }
    
    func clear(tableView: UITableView) {
        dataModel.comics.removeAll()
        dataModel.clear(tableView: tableView)
    }
}

//MARK: - Data Manager Delegate
extension ComicsViewController: DataManagerDelegate {
    func selectedRow(in tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        if dataModel.isLoadingCell(for: indexPath) == false {
            let dataEntry = dataModel.comics[indexPath.row]
            cell.textLabel?.text = dataEntry.title
            cell.detailTextLabel?.text = String(dataEntry.prices[0].price) + "$"
            cell.imageView?.image = dataEntry.image
            if dataEntry.placeholderImage {
                dataModel.downloadImage(for: dataEntry.imageURL, for: cell, at: indexPath)
                dataEntry.placeholderImage = false
            }
        }
        return cell
    }
    
    func saveLoadedImage(at inadexPath: IndexPath, image: UIImage) {
        if inadexPath.row < dataModel.comics.count {
            dataModel.comics[inadexPath.row].image = image
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
extension ComicsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: dataModel.isLoadingCell) {
            dataModel.fetchComicsData(from: catalog, for: id)
        }
    }
}
