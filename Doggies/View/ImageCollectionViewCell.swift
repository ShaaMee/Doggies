//
//  ImageCollectionViewCell.swift
//  Doggies
//
//  Created by Aleksei Pavlov on 04.11.2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dogImageView: UIImageView!
    
    var dataTask: URLSessionTask?
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dogImageView.image = nil
        // Cancelling network request if cell is out of screen
        dataTask?.cancel()
    }
}
