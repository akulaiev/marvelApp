//
//  HelperMethods.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 26.12.2020.
//

import Foundation
import UIKit

struct HelperMethods {
    
    static func showFailureAlert(title: String, message: String, controller: UIViewController?) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if let controller = controller {
                controller.present(alertVC, animated: true)
            }
            else {
                let viewController = UIApplication.shared.windows.first!.rootViewController as! CharactersViewController
                viewController.present(alertVC, animated: true)
            }
        }
    }
}
