//
//  PopImageVC.swift
//  PhotoAlbumViewer
//
//  Created by DokeR on 15.11.2018.
//  Copyright © 2018 George Sazonov. All rights reserved.
//

import UIKit

class PopImageVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var infoBackgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageToDisplay: UIImage!
    var imageTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = imageToDisplay
        imageTitleLabel.text = imageTitle
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }

    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

}
