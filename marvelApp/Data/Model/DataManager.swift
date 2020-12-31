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
    func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell
    func selectedRow(in tableView: UITableView, at indexPath: IndexPath)
}

class DataManager: NSObject {
    let networkManager = NetworkManager(requestLimit: 15)
    weak var delegate: DataManagerDelegate?
    var isFetchInProgress = false
    var totalCount = 0
    var dataCount = 0
    var cellIdentifier = ""
    
    init(delegate: DataManagerDelegate) {
        self.delegate = delegate
    }
    
    func fetchData<T: Codable>(for request: Request, type: T.Type, completion: @escaping (Result<([T], [IndexPath]?), Error>) -> Void) {
        if isFetchInProgress { return }
        isFetchInProgress = true
        networkManager.performRequest(request: request) { [self] (result: Result<APIResponse<T>, Error>) in
            self.isFetchInProgress = false
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(response):
                totalCount = totalCount == 0 ? response.data.total : totalCount
                networkManager.requestOffset += response.data.count
                dataCount += response.data.count
                if networkManager.requestOffset > response.data.limit {
                    let indexPathsToReload = calculateIndexPathsToReload(from: response.data.results.count, allDataCount: dataCount)
                    completion(.success((response.data.results, indexPathsToReload)))
                }
                else {
                    completion(.success((response.data.results, nil)))
                }
            }
        }
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
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= dataCount
    }

    //MARK: - Configuring of data representative table view
    func configureCell(_ cell: UITableViewCell) {
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 2.5
    }
    
    func clear(tableView: UITableView) {
        tableView.reloadData()
        networkManager.requestOffset = 0
        totalCount = 0
        dataCount = 0
        resetPaginationParams()
    }
}

// MARK: - Table view data source
extension DataManager: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configureCell(cell)
        return delegate!.configure(cell: cell, with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
