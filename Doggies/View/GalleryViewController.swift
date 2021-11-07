//
//  GalleryViewController.swift
//  Doggies
//
//  Created by Aleksei Pavlov on 04.11.2021.
//

import UIKit

class GalleryViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fullScreenImageView: UIImageView!
    
    var viewModel = GalleryViewControllerViewModel()
    
    private let cellsInRowCount: CGFloat = 2.0
    private let cellsSpacing: CGFloat = 8.0
    private let zoomingAnimationDuration: TimeInterval = 0.3
    
    private let refreshIndicator = UIRefreshControl()
    private var selectedThumbnailFrame: CGRect?
    private var isImageFullscreen = false
    
    // MARK: - ViewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        setupGestureRecognizers()
        
        // View Model binding
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
    
    // MARK: - Setting refresh control and collection view delegate, data source
    
    func setupViewController() {
        
        title = viewModel.breed
        collectionView.refreshControl = refreshIndicator
        refreshIndicator.addTarget(self, action: #selector(loadImageURLs), for: .valueChanged)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Setting up tap and long press gesture recognizers
    
    func setupGestureRecognizers(){
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(imageLongPressed))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.allowableMovement = 30
        longPressGesture.delegate = self
        collectionView.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGesture.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Loading images URLs from ViewModel
    
    @objc func loadImageURLs() {
        activityIndicator.startAnimating()
        viewModel.loadImageURLs()
    }
    
    // MARK: - Sharing images
    
    @objc func imageLongPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.ended { return }
        else if sender.state == UIGestureRecognizer.State.began {
            
            guard let image = getImageViewFromGesture(sender)?.image else { return }
            let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(shareController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Showing and hiding fullscreen image
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        
        switch isImageFullscreen {
        case true:
            
            // Animated zoom out to a thumbnail frame
            guard let endingFrame = selectedThumbnailFrame else { return }
            
            UIView.animate(withDuration: zoomingAnimationDuration) { [weak self] in
                
                self?.fullScreenImageView.frame = endingFrame
                
            } completion: { [weak self] _ in
                
                self?.switchImageToFullScreen(false)
                self?.view.setNeedsLayout()
            }
            
        default:
            
            // Getting the thumbnail frame, saving it and animating image to fullscreen
            guard let imageView = getImageViewFromGesture(sender) else { return }
            fullScreenImageView.image = imageView.image
            fullScreenImageView.frame = imageView.bounds
            switchImageToFullScreen(true)
            
            // Converting thumbnail local frame to global frame
            selectedThumbnailFrame = imageView.superview?.convert(imageView.frame, to: nil)
            
            guard let startingFrame = selectedThumbnailFrame else { return }
            
            // Setting the starting image frame for future zooming out
            fullScreenImageView.frame = startingFrame
            
            UIView.animate(withDuration: zoomingAnimationDuration) { [weak self] in
                
                guard let self = self,
                      let backgroundView = self.fullScreenImageView.superview
                else { return }
                
                // Calculating the fullscreen image frame
                guard let fullScreenImage = self.fullScreenImageView.image else { return }
                
                let screenAspect = backgroundView.frame.height / backgroundView.frame.width
                let imageAspect = fullScreenImage.size.height / fullScreenImage.size.width
                
                if screenAspect > imageAspect {
                    self.fullScreenImageView.frame.size = CGSize(width: backgroundView.frame.width, height: backgroundView.frame.width * imageAspect)
                } else {
                    self.fullScreenImageView.frame.size = CGSize(width: backgroundView.frame.height / imageAspect, height: backgroundView.frame.height)
                }
                self.fullScreenImageView.center = backgroundView.center
            }
        }
    }
    
    // MARK: - Getting image view from tap gesture
    
    func getImageViewFromGesture(_ sender: UIGestureRecognizer) -> UIImageView? {
        
        let location = sender.location(in: self.collectionView)
        let indexPath = collectionView.indexPathForItem(at: location)
        
        guard let index = indexPath,
              let cell = collectionView.cellForItem(at: index) as? ImageCollectionViewCell,
              let imageView = cell.dogImageView else {
            print("Can't get image")
            return nil
        }
        return imageView
    }
    
    // MARK: - Toggling states of navigation bar and fullscreen view
    
    func switchImageToFullScreen(_ state: Bool){
        navigationController?.navigationBar.isHidden = state
        fullScreenImageView.superview?.isHidden = !state
        fullScreenImageView.superview?.isUserInteractionEnabled = state
        isImageFullscreen = state
    }
}

// MARK: - UICollectionView delegate, data source and flow layout methods implementation

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageURLs.value.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellIdentifier, for: indexPath)
        guard let imageCell = cell as? ImageCollectionViewCell else { return cell }
        
        // Setting the dummy image before we got actual image
        imageCell.dogImageView.image = UIImage(systemName: viewModel.dummyImageName)
        
        guard viewModel.imageURLs.value.indices.contains(indexPath.row) else { return imageCell }
        
        let searchURLString = viewModel.imageURLs.value[indexPath.row]
        
        // Getting image from server or cache
        imageCell.dataTask = ImageService.shared.image(forURLString: searchURLString) { [weak imageCell] image in
            
            DispatchQueue.main.async {
                imageCell?.dogImageView.image = image
            }
        }
        return imageCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Setting the size for items in collection view
        let collectionViewFrame = collectionView.frame
        let cellInset = ((cellsInRowCount + 1) * cellsSpacing) / cellsInRowCount
        let cellWidth = collectionViewFrame.width / cellsInRowCount - cellInset
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
