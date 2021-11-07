//
//  BreedsListTableViewController.swift
//  Doggies
//
//  Created by Aleksei Pavlov on 04.11.2021.
//

import UIKit

class BreedsListTableViewController: UITableViewController {
    
    private var viewModel = BreedsListTableViewControllerViewModel()
    private let cellId = "breedCeel"
    private let rowHeight: CGFloat = 60
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let refreshIndicator = UIRefreshControl()

    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        
        // View Model binding
        viewModel.breeds.bind({ [weak self]_ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.refreshIndicator.endRefreshing()
            }
        })
        
        fetchData()
    }
    
    // MARK: - Setting refresh control and activity indicator
    
    func setupViewController() {
        title = viewModel.titleText
        refreshIndicator.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        tableView.refreshControl = refreshIndicator
        activityIndicator.center = CGPoint(x: view.center.x, y: rowHeight / 2)
        view.addSubview(activityIndicator)
    }
    
    // MARK: - Fetching breeds list from server
    
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
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showGallery",
              let imagesVC = segue.destination as? GalleryViewController,
              let cell = sender as? UITableViewCell
        else { return }
        imagesVC.viewModel.breed = cell.textLabel?.text
    }
}
