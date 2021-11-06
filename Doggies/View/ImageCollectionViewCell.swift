//
//  ImageCollectionViewCell.swift
//  Doggies
//
//  Created by user on 04.11.2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dogImageView: UIImageView!
    
    var dataTask: URLSessionTask?
        
    override func prepareForReuse() {
        super.prepareForReuse()
        dogImageView.image = nil
        dataTask?.cancel()
    }
}
