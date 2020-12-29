//
//  ComicsDataEntry.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 27.12.2020.
//

import Foundation
import UIKit

// MARK: - Result
class ComicsDataEntry: Codable {
    let title: String
    let prices: [Price]
    let imageURLComponents: ImageURL
    var image = UIImage(named: "imagePlaceholder")
    var placeholderImage = true
    
    var imageURL: String {
        return imageURLComponents.urlPath + "." + imageURLComponents.urlExtension
    }
    
    enum CodingKeys: String, CodingKey {
        case title, prices
        case imageURLComponents = "thumbnail"
    }
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
