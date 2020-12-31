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
        fetchData(for: Request.showComics(catalog: catalog, id: id), type: ComicsDataEntry.self) { [self] result in
            switch result {
            case let .success((fetchedData, indexPaths)):
                comics.append(contentsOf: fetchedData)
                delegate?.onFetchCompleted(with: indexPaths)
            case let .failure(error):
                delegate?.onFetchFailed(with: error.localizedDescription)
            }
        }
    }
}

