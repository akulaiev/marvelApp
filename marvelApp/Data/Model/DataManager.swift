//
//  DataManager.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

class PaginationData {
    var offset = 0, limit = 0, total = 0, count = 0
    
    func update(offset: Int, limit: Int, total: Int, count: Int) {
        self.count = count
        self.limit = limit
        self.offset = self.offset + count < self.total ? self.offset + count : count - 1
        self.total = total
    }
    
    func reset() {
        self.count = 0
        self.limit = 0
        self.offset = 0
        self.total = 0
    }
}

protocol DataManagerDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

class DataManager {
    let networkManager = NetworkManager(requestLimit: 15)
    weak var delegate: DataManagerDelegate?
    
    init(delegate: DataManagerDelegate) {
        self.delegate = delegate
    }
    
    func downloadImage(for url: ImageURL, for cell: UITableViewCell) {
        networkManager.performRequest(request: .downloadImage("\(url.urlPath).\(url.urlExtension)")) { (result: Result<Data, Error>) in
            switch result {
            case let .success(data):
                if let image = UIImage(data: data) {
                    cell.imageView?.image = image
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Pagination methods
    func calculateIndexPathsToReload<DataType : Codable>(from newData: [DataType], allData: [DataType]) -> [IndexPath] {
          let startIndex = allData.count - newData.count
          let endIndex = startIndex + newData.count
          return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        }

    func visibleIndexPathsToReload(indexPaths: [IndexPath], tableView: UITableView) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }


    //MARK: - Configuring of data representative table view
    func configureCell(_ cell: UITableViewCell) {
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 2.5
    }
}
