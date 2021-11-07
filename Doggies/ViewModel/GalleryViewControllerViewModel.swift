//
//  GalleryViewControllerViewModel.swift
//  Doggies
//
//  Created by Aleksei Pavlov on 06.11.2021.
//

import Foundation

class GalleryViewControllerViewModel {
    
    var breed: String?
    var imageURLs: Observable<[String]> = Observable([])
    let cellIdentifier = "imageCell"
    let dummyImageName = "clock"
    
    // Assembling URL from URLComponents for safe encoding of dogBreed string
    private lazy var requestURL: URL? = {
        guard let dogBreed = breed else { return nil}
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dog.ceo"
        components.path = "/api/breed/\(dogBreed)/images"
        return components.url
    }()
    
    // Fetching list of images URLs
    func loadImageURLs() {
        
        guard let url = requestURL else { return }
        
        NetworkService.shared.fetchRequest(url) { [weak self] jsonData in
            guard let data = jsonData,
                  let dogImagesAdresses = try? JSONDecoder().decode(DogImages.self, from: data),
                  let imagesURLStrings = dogImagesAdresses.message else { return }
            self?.imageURLs.value = imagesURLStrings
        }
    }
}
