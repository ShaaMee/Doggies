//
//  NetworkService.swift
//  Doggies
//
//  Created by Aleksei Pavlov on 06.11.2021.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    func fetchRequest(_ url: URL, completion: @escaping (Data?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200
            else { return }
            completion(data)
        }.resume()
    }
}
