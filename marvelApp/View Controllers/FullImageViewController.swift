//
//  FullImageViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 29.12.2020.
//

import UIKit

class FullImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageToShow: UIImage!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let image = imageToShow {
            imageView.image = image
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
