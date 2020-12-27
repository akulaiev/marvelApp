//
//  SearchCatalogDataEntry.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 23.12.2020.
//

import Foundation
import UIKit

//MARK:- Data entry for character/author
class SearchCatalogDataEntry: Codable {

    let name: String?
    let fullName: String?
    let id: Int
    let imageURLComponents: ImageURL
    var image = UIImage(named: "imagePlaceholder")
    var placeholderImage = true
    
    var imageURL: String {
        return imageURLComponents.urlPath + "." + imageURLComponents.urlExtension
    }
    
    enum CodingKeys: String, CodingKey {
        case name, fullName, id
        case imageURLComponents = "thumbnail"
    }
}
