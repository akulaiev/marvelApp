//
//  ComicsDataEntry.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 27.12.2020.
//

import Foundation

// MARK: - Result
struct ComicsDataEntry: Codable {
    let title: String
    let prices: [Price]
    let thumbnail: ImageURL
}

// MARK: Price
struct Price: Codable {
    let type: PriceType
    let price: Double
}

enum PriceType: String, Codable {
    case digitalPurchasePrice = "digitalPurchasePrice"
    case printPrice = "printPrice"
}
