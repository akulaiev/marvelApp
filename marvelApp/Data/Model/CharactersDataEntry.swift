//
//  CharactersDataEntry.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

class CharactersDataEntry: Codable {

    let name: String
    let id: Int
    let imageURLComponents: ImageURL
    var image = UIImage(named: "imagePlaceholder")
    var placeholderImage = true
    
    var imageURL: String {
        return imageURLComponents.urlPath + "." + imageURLComponents.urlExtension
    }
    
    enum CodingKeys: String, CodingKey {
        case name, id
        case imageURLComponents = "thumbnail"
    }
}
