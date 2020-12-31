//
//  APIResponses.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 23.12.2020.
//

import Foundation

//MARK:- Response struct
struct APIResponse<T: Codable>: Codable {
    let data: ResponseData<T>
}

// MARK: Response DataClass
struct ResponseData<T: Codable>: Codable {
    let offset, limit, total, count: Int
    let results: [T]
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

