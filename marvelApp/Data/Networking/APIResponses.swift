//
//  APIResponses.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 23.12.2020.
//

import Foundation

//MARK:- Character list response struct
struct CharacterResponse: Codable {
    let data: CharacterData
}

// MARK: Character DataClass
struct CharacterData: Codable {
    let offset, limit, total, count: Int
    let results: [CharactersDataEntry]
}

//MARK:- Creator list response struct
struct AuthorResponse: Codable {
    let data: AuthorData
}

// MARK: Author DataClass
struct AuthorData: Codable {
    let offset, limit, total, count: Int
    let results: [AuthorsDataEntry]
}

// MARK: - ComicsResponse
struct ComicsResponse: Codable {
    let data: ComicsData
}

// MARK: Comics DataClass
struct ComicsData: Codable {
    let offset, limit, total, count: Int
    let results: [ComicsDataEntry]
}

//MARK: Image Url struct
struct ImageURL: Codable {
    let urlPath: String
    let urlExtension: String
    
    enum CodingKeys: String, CodingKey {
        case urlPath = "path"
        case urlExtension = "extension"
    }
}
