//
//  CharacterViewModel.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

class Character {
    var result = [CharactersDataEntry]()
    var paginationData = PaginationData()
    
    init(from characterData: CharacterData) {
  
        self.result = characterData.results
        paginationData.update(offset: characterData.offset, limit: characterData.limit, total: characterData.total, count: characterData.count)
    }
    
    func update(characterData: CharacterData) {
        if !self.result.isEmpty {
            self.result.append(contentsOf: characterData.results)
        }
        else {
            self.result = characterData.results
        }
        paginationData.update(offset: characterData.offset, limit: characterData.limit, total: characterData.total, count: characterData.count)
    }
}

class CharacterViewModel: DataManager {
    var characters: Character!
    
    func fetchCharacterData(for query: String) {
        super.networkManager.performRequest(request: Request.searchCharacters(query)) { (result: Result<CharacterResponse, Error>) in
            switch result {
            case let .failure(error):
                self.delegate?.onFetchFailed(with: error.localizedDescription)
            case let .success(response):
                print(self.characters?.paginationData.offset ?? "no offset for you")
                guard let characters = self.characters else {
                    self.characters = Character(from: response.data)
                    self.delegate?.onFetchCompleted(with: .none)
                    return
                }
                characters.update(characterData: response.data)
                let indexPathsToReload = super.calculateIndexPathsToReload(from: response.data.results, allData: characters.result)
                self.delegate?.onFetchCompleted(with: indexPathsToReload)
            }
        }
    }
}
