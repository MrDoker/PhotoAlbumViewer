//
//  ImageCollectionViewCell.swift
//  PhotoAlbumViewer
//
//  Created by DokeR on 15.11.2018.
//  Copyright © 2018 George Sazonov. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    func configCellFor(imageModel: ImageModel) {
        infoLabel.text = imageModel.title
        ImageDownloadService.instance.loadImageUsingCacheWithUrlString(imageModel.url) { (image) in
            guard let downloadedImage = image else {
                //load error image
                return
            }
            self.imageView.image = downloadedImage
        }
    }
}
