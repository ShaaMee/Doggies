//
//  ImageService.swift
//  Doggies
//
//  Created by user on 06.11.2021.
//

import UIKit

class ImageService {
    static let shared = ImageService()
    
    func image(forURLString urlString: String, completion: @escaping (UIImage?) -> () ) -> URLSessionTask? {
        
        guard let url = URL(string: urlString) else { return nil}
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let image = UIImage(data: data)
            else { return }
            completion(image)
        }
        dataTask.resume()
        return dataTask
    }
}
