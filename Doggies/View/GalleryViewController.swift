//
//  GalleryViewController.swift
//  Doggies
//
//  Created by user on 04.11.2021.
//

import UIKit

class GalleryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fullScreenImageView: UIImageView!
    
    var viewModel = GalleryViewControllerViewModel()

    private let cellsInRowCount: CGFloat = 2.0
    private let cellsSpacing: CGFloat = 8.0
    
    private let refreshIndicator = UIRefreshControl()
    private var selectedThumbnailFrame: CGRect?
    private var isImageFullscreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.breed

        collectionView.refreshControl = refreshIndicator
        
        refreshIndicator.addTarget(self, action: #selector(loadImageURLs), for: .valueChanged)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(imageLongPressed))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.allowableMovement = 30
        longPressGesture.delegate = self
        collectionView.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGesture.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(tapGesture)
        
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
    
    @objc func imageLongPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.ended { return }
        else if sender.state == UIGestureRecognizer.State.began {
            
            guard let image = getImageViewFromGesture(sender)?.image else { return }
            let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(shareController, animated: true, completion: nil)
        }
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        switch isImageFullscreen {
        case true:
            
            guard let endingFrame = selectedThumbnailFrame else { return }
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.fullScreenImageView.frame = endingFrame
            } completion: { [weak self] _ in
                self?.fullScreenImageView.superview?.isHidden = true
                self?.fullScreenImageView.superview?.isUserInteractionEnabled = false
                self?.isImageFullscreen = false
                self?.navigationController?.navigationBar.isHidden = false
                self?.view.setNeedsLayout()
            }


        default:
            guard let imageView = getImageViewFromGesture(sender) else { return }
            navigationController?.navigationBar.isHidden = true
            fullScreenImageView.image = imageView.image
            fullScreenImageView.frame = imageView.bounds
            fullScreenImageView.superview?.isHidden = false
            fullScreenImageView.superview?.isUserInteractionEnabled = true
            isImageFullscreen = true
            
            selectedThumbnailFrame = imageView.superview?.convert(imageView.frame, to: nil)
            if let startingFrame = selectedThumbnailFrame {
                fullScreenImageView.frame = startingFrame
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self = self,
                          let backgroundView = self.fullScreenImageView.superview else { return }
                    let screenAspect = backgroundView.frame.height / backgroundView.frame.width
                    let imageAspect = self.fullScreenImageView.image!.size.height / self.fullScreenImageView.image!.size.width
                    
                    if screenAspect > imageAspect {
                        self.fullScreenImageView.frame.size = CGSize(width: backgroundView.frame.width, height: backgroundView.frame.width * imageAspect)
                    } else {
                        self.fullScreenImageView.frame.size = CGSize(width: backgroundView.frame.height / imageAspect, height: backgroundView.frame.height)
                    }
                    self.fullScreenImageView.center = backgroundView.center
                }
            }
            
            
            
        }
    }
    
    func getImageViewFromGesture(_ sender: UIGestureRecognizer) -> UIImageView? {
        
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        guard let index = indexPath,
              let cell = self.collectionView.cellForItem(at: index) as? ImageCollectionViewCell,
              let imageView = cell.dogImageView else {
            print("Can't get image")
            return nil
        }
        return imageView
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
