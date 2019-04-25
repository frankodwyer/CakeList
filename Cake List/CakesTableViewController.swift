//
//  CakesTableViewController.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.
//  Copyright © 2019 Stewart Hart. All rights reserved.
//

import UIKit

class CakesTableViewController: UITableViewController {

    var model: CakesViewModel!

    // TODO: could also add prefetching of rows to further avoid glitching while scrolling https://developer.apple.com/documentation/uikit/uitableviewdatasourceprefetching

    override func viewDidLoad() {
        super.viewDidLoad()

        model = CakesViewModel() { [unowned self] in
            if self.model.isLoading {
                self.refreshControl?.beginRefreshing()
            } else {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()

                if let error = self.model.error {
                    // TODO: this would probably need to be replaced with something better for typical expected errors such as network errors etc!
                    let alert = Alerts.alert(with: error)
                    self.present(alert, animated: true)
                }
            }
        }

        model.getData()
    }

    @IBAction func refreshControlTriggered(_ sender: Any) {
        model.getData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CakeCell", for: indexPath) as! CakeCell

        let cellViewModel = model.viewModelForCell(at: indexPath)

        cell.configure(with: cellViewModel)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


