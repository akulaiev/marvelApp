//
//  AuthorsViewModel.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

class Author {
    var result = [AuthorsDataEntry]()
    var paginationData = PaginationData()
    
    init(from authorData: AuthorData) {
  
        self.result = authorData.results
        paginationData.update(offset: authorData.offset, limit: authorData.limit, total: authorData.total, count: authorData.count)
    }
    
    func update(authorData: AuthorData) {
        if !self.result.isEmpty {
            self.result.append(contentsOf: authorData.results)
        }
        else {
            self.result = authorData.results
        }
        paginationData.update(offset: authorData.offset, limit: authorData.limit, total: authorData.total, count: authorData.count)
    }
}

class AuthorViewModel: DataManager {
    var authors: Author!
    
    func fetchAuthorData(for query: String) {
        super.networkManager.performRequest(request: Request.searchAuthors(query)) { (result: Result<AuthorResponse, Error>) in
            switch result {
            case let .failure(error):
                self.delegate?.onFetchFailed(with: error.localizedDescription)
            case let .success(response):
                guard let authors = self.authors else {
                    self.authors = Author(from: response.data)
                    self.delegate?.onFetchCompleted(with: .none)
                    return
                }
                authors.update(authorData: response.data)
                let indexPathsToReload = super.calculateIndexPathsToReload(from: response.data.results, allData: authors.result)
                self.delegate?.onFetchCompleted(with: indexPathsToReload)
            }
        }
    }
}
