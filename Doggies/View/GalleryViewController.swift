//
//  GalleryViewController.swift
//  Doggies
//
//  Created by user on 04.11.2021.
//

import UIKit

class GalleryViewController: UIViewController {
    
    //private let viewModel: GalleryViewViewModel?
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = GalleryViewControllerViewModel()

    private let cellsInRowCount: CGFloat = 2.0
    private let cellsSpacing: CGFloat = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        viewModel.imageURLs.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        loadImageURLs()
    }
    
    @objc func loadImageURLs() {
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
        let index = indexPath
        guard viewModel.imageURLs.value.indices.contains(indexPath.row) else { return imageCell }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let searchURLString = self?.viewModel.imageURLs.value[indexPath.row],
                  let url = URL(string: searchURLString),
                  let urlData = try? Data(contentsOf: url),
                  let image = UIImage(data: urlData)
            else { return }
            
            DispatchQueue.main.async {
                guard indexPath == index else { return }
                imageCell.dogImageView.image = image
            }
            
        }
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewFrame = collectionView.frame
        let cellInset = ((cellsInRowCount + 1) * cellsSpacing) / cellsInRowCount
        let cellWidth = collectionViewFrame.width / cellsInRowCount - cellInset
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
