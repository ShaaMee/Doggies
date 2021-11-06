//
//  GalleryViewController.swift
//  Doggies
//
//  Created by user on 04.11.2021.
//

import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel = GalleryViewControllerViewModel()

    private let cellsInRowCount: CGFloat = 2.0
    private let cellsSpacing: CGFloat = 8.0
    
    
    
    private let refreshIndicator = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.breed

        collectionView.refreshControl = refreshIndicator
        
        refreshIndicator.addTarget(self, action: #selector(loadImageURLs), for: .valueChanged)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        viewModel.imageURLs.bind { [weak self] url in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.refreshIndicator.endRefreshing()
                guard !url.isEmpty else { return }
                self?.activityIndicator.stopAnimating()
            }
        }
        
        loadImageURLs()
    }
    
    @objc func loadImageURLs() {
        activityIndicator.startAnimating()
        viewModel.loadImageURLs()
    }
}


extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageURLs.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        guard let imageCell = cell as? ImageCollectionViewCell else { return cell }
        
        imageCell.dogImageView.image = UIImage(systemName: "clock")
        
        guard viewModel.imageURLs.value.indices.contains(indexPath.row) else { return imageCell}
        let searchURLString = viewModel.imageURLs.value[indexPath.row]
        
        imageCell.dataTask = ImageService.shared.image(forURLString: searchURLString, completion: { [weak imageCell] image in
            DispatchQueue.main.async {
                imageCell?.dogImageView.image = image
            }
        })
        
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewFrame = collectionView.frame
        let cellInset = ((cellsInRowCount + 1) * cellsSpacing) / cellsInRowCount
        let cellWidth = collectionViewFrame.width / cellsInRowCount - cellInset
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
