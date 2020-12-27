//
//  MarvelDataModel.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 24.12.2020.
//

import Foundation
import UIKit

protocol MarvelDataModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

class MarvelDataModel {
    
    let networkManager = DefaultNetworkManager(requestLimit: 15)
    var catalogData = [SearchCatalogDataEntry]()
    var comicsForCatalog = [ComicsDataEntry]()
    var isFetchInProgress = false
    var totalCharactersCount = 0
    
    weak var delegate: MarvelDataModelDelegate?
    
    init(delegate: MarvelDataModelDelegate) {
        self.delegate = delegate
    }
    
    func search(for searchRequest: Request) {
        guard !isFetchInProgress else {return}
        isFetchInProgress = true
        networkManager.performRequest(request: searchRequest) { [self] (result: Result<DataResponse, Error>) in
            self.isFetchInProgress = false
            switch result {
            case let .failure(error):
                delegate?.onFetchFailed(with: error.localizedDescription)
            case let .success(response):
//                print("caller: \(delegate is AuthorsTableViewController ? "author" : "character"), request: \(searchRequest.queryItems), offset: \(networkManager.requestOffset), total: \(response.data.total)")
                totalCharactersCount = totalCharactersCount == 0 ? response.data.total : totalCharactersCount
                networkManager.requestOffset += response.data.count
                catalogData.append(contentsOf: response.data.results)
                if networkManager.requestOffset > response.data.limit {
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: response.data.results)
                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                }
                else {
                    self.delegate?.onFetchCompleted(with: .none)
                }
            }
        }
    }
    
    func downloadImage(of character: SearchCatalogDataEntry, for cell: UITableViewCell) {
        networkManager.performRequest(request: .downloadImage(character.imageURL)) { (result: Result<Data, Error>) in
            switch result {
            case let .success(data):
                if let image = UIImage(data: data) {
                    cell.imageView?.image = image
                    character.image = image
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Pagination methods
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= catalogData.count
    }

    func visibleIndexPathsToReload(indexPaths: [IndexPath], tableView: UITableView) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    private func calculateIndexPathsToReload(from newCharacters: [SearchCatalogDataEntry]) -> [IndexPath] {
      let startIndex = catalogData.count - newCharacters.count
      let endIndex = startIndex + newCharacters.count
      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    //MARK: - Configuring of data representative table view
    func configureCell(_ cell: UITableViewCell, withDataAt indexPath: IndexPath) {
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.borderWidth = 2.5
        if !isLoadingCell(for: indexPath) {
            let dataEntry = catalogData[indexPath.row]
            cell.textLabel?.text = dataEntry.name != nil ? dataEntry.name : dataEntry.fullName
            cell.imageView?.image = dataEntry.image
            if dataEntry.placeholderImage {
                downloadImage(of: dataEntry, for: cell)
                dataEntry.placeholderImage = false
            }
        }
    }
    
    func clear(tableView: UITableView) {
        catalogData.removeAll()
        tableView.reloadData()
        networkManager.requestOffset = 0
        totalCharactersCount = 0
    }
}
