//
//  AuthorsDataEntry.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 28.12.2020.
//

import Foundation
import UIKit

//MARK:- Data entry for author
class AuthorsDataEntry: Codable {

    let fullName: String?
    let id: Int
    let imageURLComponents: ImageURL
    var image = UIImage(named: "imagePlaceholder")
    var placeholderImage = true
    
    var imageURL: String {
        return imageURLComponents.urlPath + "." + imageURLComponents.urlExtension
    }
    
    enum CodingKeys: String, CodingKey {
        case fullName, id
        case imageURLComponents = "thumbnail"
    }
}
