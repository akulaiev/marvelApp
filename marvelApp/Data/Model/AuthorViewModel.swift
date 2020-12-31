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
    
    func fetchAuthorData(for query: String/*, completion: @escaping (Result<(APIResponse<AuthorsDataEntry>, [IndexPath]?), Error>) -> Void*/) {
        fetchData(for: Request.searchAuthors(query), type: AuthorsDataEntry.self) { [self] result in
            switch result {
            case let .success((fetchedData, indexPaths)):
                authors.append(contentsOf: fetchedData)
                delegate?.onFetchCompleted(with: indexPaths)
            case let .failure(error):
                delegate?.onFetchFailed(with: error.localizedDescription)
            }
        }
    }
}

