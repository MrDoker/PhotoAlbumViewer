//
//  DataService.swift
//  PhotoAlbumViewer
//
//  Created by DokeR on 15.11.2018.
//  Copyright © 2018 George Sazonov. All rights reserved.
//

import Foundation

class DataService {
    
    func fetchDataFromJSON(completion: @escaping (_ images:[ImageModel]?) -> ()) {
        let urlString = "https://jsonplaceholder.typicode.com/photos"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil)
                    return
                }
                
                var imageModelArray = [ImageModel]()
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    
                    imageModelArray = try decoder.decode([ImageModel].self, from: data)
                    
                    completion(imageModelArray)
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                    completion(nil)
                    return
                }
            }
        }.resume()
    }
    
}
