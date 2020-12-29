//
//  DataManager.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

protocol DataManagerDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
    func saveLoadedImage(at inadexPath: IndexPath, image: UIImage)
}

class DataManager {
    let networkManager = NetworkManager(requestLimit: 15)
    weak var delegate: DataManagerDelegate?
    var isFetchInProgress = false
    var totalCount = 0
    var dataCount = 0
    
    init(delegate: DataManagerDelegate) {
        self.delegate = delegate
    }
    
    func downloadImage(for url: String, for cell: UITableViewCell, at indexPath: IndexPath) {
        networkManager.performRequest(request: .downloadImage(url)) { [self] (result: Result<Data, Error>) in
            switch result {
            case let .success(data):
                if let image = UIImage(data: data) {
                    cell.imageView?.image = image
                    delegate?.saveLoadedImage(at: indexPath, image: image)
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Pagination methods
    func calculateIndexPathsToReload(from newDataCount: Int, allDataCount: Int) -> [IndexPath] {
        let startIndex = allDataCount - newDataCount
        let endIndex = startIndex + newDataCount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func visibleIndexPathsToReload(indexPaths: [IndexPath], tableView: UITableView) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }

    func resetPaginationParams() {
        totalCount = 0
        networkManager.requestOffset = 0
        dataCount = 0
    }

    //MARK: - Configuring of data representative table view
    func configureCell(_ cell: UITableViewCell) {
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 2.5
    }
}
