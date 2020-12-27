//
//  ComicsListTableViewController.swift
//  marvelApp
//
//  Created by Anna Kulaieva on 26.12.2020.
//

import UIKit

class ComicsListTableViewController: UITableViewController {

    var searchData: SearchCatalogDataEntry!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
