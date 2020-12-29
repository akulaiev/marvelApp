//
//  ComicsViewModel.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 29.12.2020.
//

import Foundation
import UIKit

class ComicsViewModel: DataManager {
    var comics = [ComicsDataEntry]()
    
    func fetchComicsData(from catalog: String, for id: String) {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        super.networkManager.performRequest(request: Request.showComics(catalog: catalog, id: id)) { [self] (result: Result<ComicsResponse, Error>) in
            self.isFetchInProgress = false
            switch result {
            case let .failure(error):
                delegate?.onFetchFailed(with: error.localizedDescription)
            case let .success(response):
                totalCount = totalCount == 0 ? response.data.total : totalCount
                networkManager.requestOffset += response.data.count
                dataCount += response.data.count
                comics.append(contentsOf: response.data.results)
                if networkManager.requestOffset > response.data.limit {
                    let indexPathsToReload = calculateIndexPathsToReload(from: response.data.results.count, allDataCount: comics.count)
                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                }
                else {
                    self.delegate?.onFetchCompleted(with: .none)
                }
            }
        }
    }
}

