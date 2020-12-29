//
//  AuthorViewModel.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

class AuthorViewModel: DataManager {
    var authors = [AuthorsDataEntry]()
    
    func fetchAuthorData(for query: String) {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        super.networkManager.performRequest(request: Request.searchAuthors(query)) { [self] (result: Result<AuthorResponse, Error>) in
            self.isFetchInProgress = false
            switch result {
            case let .failure(error):
                delegate?.onFetchFailed(with: error.localizedDescription)
            case let .success(response):
                totalCount = totalCount == 0 ? response.data.total : totalCount
                networkManager.requestOffset += response.data.count
                dataCount += response.data.count
                authors.append(contentsOf: response.data.results)
                if networkManager.requestOffset > response.data.limit {
                    let indexPathsToReload = calculateIndexPathsToReload(from: response.data.results.count, allDataCount: authors.count)
                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                }
                else {
                    self.delegate?.onFetchCompleted(with: .none)
                }
            }
        }
    }
}

