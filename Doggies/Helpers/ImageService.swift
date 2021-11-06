//
//  ImageService.swift
//  Doggies
//
//  Created by user on 06.11.2021.
//

import UIKit

class ImageService {
    static let shared = ImageService()
    
    var imageCache = NSCache<NSString, UIImage>()
    
    func image(forURLString urlString: String, completion: @escaping (UIImage?) -> () ) -> URLSessionTask? {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
        } else {
            
            guard let url = URL(string: urlString) else { return nil}
            
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
            
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let image = UIImage(data: data)
                else { return }
                
                self.imageCache.setObject(image, forKey: urlString as NSString)
                completion(image)
            }
            dataTask.resume()
            return dataTask
        }
        return nil
    }
}
