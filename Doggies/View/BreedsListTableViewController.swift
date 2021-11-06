//
//  BreedsListTableViewController.swift
//  Doggies
//
//  Created by user on 04.11.2021.
//

import UIKit

class BreedsListTableViewController: UITableViewController {
    
    private let cellId = "breedCeel"
    private let rowHeight: CGFloat = 60
    private var viewModel = BreedsListTableViewControllerViewModel()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let refreshIndicator = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshIndicator.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        title = viewModel.titleText
        tableView.refreshControl = refreshIndicator
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.center.x, y: rowHeight / 2)
        
        viewModel.breeds.bind({ [weak self]_ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.refreshIndicator.endRefreshing()
                
            }
        })
        
        fetchData()
    }
    
    @objc func fetchData() {
        activityIndicator.startAnimating()
        self.viewModel.fetchBreeds()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.breeds.value.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = viewModel.breeds.value[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showGallery",
              let imagesVC = segue.destination as? GalleryViewController,
              let cell = sender as? UITableViewCell
        else { return }
        imagesVC.viewModel.breed = cell.textLabel?.text
    }
}
