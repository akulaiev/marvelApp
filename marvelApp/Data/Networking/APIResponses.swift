//
//  APIResponses.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 23.12.2020.
//

import Foundation

// MARK: Catalog/Author DataClass
struct SearchCatalogDataClass: Codable {
    let offset, limit, total, count: Int
    let results: [SearchCatalogDataEntry]
}

//MARK:- Character or creator list response struct
struct DataResponse: Codable {
    let data: SearchCatalogDataClass
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
