//
//  BreedsListTableViewControllerViewModel.swift
//  Doggies
//
//  Created by user on 04.11.2021.
//

import Foundation

class BreedsListTableViewControllerViewModel {
    
    let titleText = "Doggies"
    private(set) var breeds: Observable<[String]> = Observable([])
    
    func fetchBreeds() {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else { return }
        NetworkService.shared.fetchRequest(url) { data in
            
            guard let data = data else { return }
            guard let dogs = try? JSONDecoder().decode(Dogs.self, from: data) else {
                print("Can't decode JSON")
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
