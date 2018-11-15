//
//  ImageDownloadService.swift
//  PhotoAlbumViewer
//
//  Created by DokeR on 15.11.2018.
//  Copyright © 2018 George Sazonov. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloadService {
    static let instance = ImageDownloadService()
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    func loadImageUsingCacheWithUrlString(_ urlString: String, handler: @escaping (_ image: UIImage?) ->() ) {
        //check cache for image
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            handler(cachedImage)
            return
        }
        
        //download and cache image
        guard let url = URL(string: urlString) else {
            print("Error of creating URL")
            handler(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription ?? "!!!error downloading Image!!")
                handler(nil)
                return
            }
            
            DispatchQueue.main.async {
                guard let downloadedImage = UIImage(data: data!) else {return}
                self.imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                handler(downloadedImage)
            }
            }.resume()
    }
}
