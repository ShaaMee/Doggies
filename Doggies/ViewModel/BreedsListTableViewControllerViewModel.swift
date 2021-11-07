//
//  BreedsListTableViewControllerViewModel.swift
//  Doggies
//
//  Created by Aleksei Pavlov on 04.11.2021.
//

import Foundation

class BreedsListTableViewControllerViewModel {
    
    let titleText = "Doggies"
    private let requestURLString = "https://dog.ceo/api/breeds/list/all"
    private(set) var breeds: Observable<[String]> = Observable([])
    
    // Fetching and decoding breeds list from server
    func fetchBreeds() {
        guard let url = URL(string: requestURLString) else { return }
        
        NetworkService.shared.fetchRequest(url) { data in
            
            guard let data = data,
                  let dogs = try? JSONDecoder().decode(Dogs.self, from: data)
            else {
                print("No data or can't decode JSON")
                return
            }
            
            var allBreeds = [String]()
            dogs.message?.forEach {
                allBreeds.append($0.key)
            }
            self.breeds.value = allBreeds
        }
    }
}
