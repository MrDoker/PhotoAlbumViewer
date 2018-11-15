//
//  RoundedImageView.swift
//  PhotoAlbumViewer
//
//  Created by DokeR on 15.11.2018.
//  Copyright © 2018 George Sazonov. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2
    }
    
}
