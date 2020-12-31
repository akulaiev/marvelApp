//
//  CharacterViewModel.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

class CharacterViewModel: DataManager {
    var characters = [CharactersDataEntry]()
    
    func fetchCharacterData(for query: String) {
        fetchData(for: Request.searchCharacters(query), type: CharactersDataEntry.self) { [self] result in
            switch result {
            case let .success((fetchedData, indexPaths)):
                characters.append(contentsOf: fetchedData)
                delegate?.onFetchCompleted(with: indexPaths)
            case let .failure(error):
                delegate?.onFetchFailed(with: error.localizedDescription)
            }
        }
    }
}
