//
//  ViewController.swift
//  PhotoAlbumViewer
//
//  Created by DokeR on 15.11.2018.
//  Copyright © 2018 George Sazonov. All rights reserved.
//

import UIKit

struct ImageForPass {
    let title: String
    let image: UIImage
}

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let refresh = UIRefreshControl()
    
    var imageModelArray = [ImageModel]()
    
    var imageForPass: ImageForPass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.2431372549, blue: 0.3294117647, alpha: 1)
        collectionView.addSubview(refresh)
        
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        registerForPreviewing(with: self, sourceView: collectionView!)

        //self.collectionView.scrollToItem(at: IndexPath(row: 20, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)

        fetchData()
    }
    
    func fetchData() {
        refresh.beginRefreshing()
        let dataService = DataService()
        dataService.fetchDataFromJSON { (imagesArray) in
            if let imagesArray = imagesArray {
                self.imageModelArray = imagesArray
                self.refresh.endRefreshing()
                self.collectionView.reloadData()
            } else {
                print("Error: Cant Fetch Data From JSON")
            }
        }
    }
    
    @objc func handleRefresh() {
        ImageDownloadService.instance.imageCache.removeAllObjects()
        fetchData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPopImageVC" {
            let popVC = segue.destination as? PopImageVC
            popVC?.imageTitle = imageForPass?.title
            popVC?.imageToDisplay = imageForPass?.image
        }
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageModelArray.count/100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ImageCollectionViewCell {
            cell.configCellFor(imageModel: imageModelArray[indexPath.row])
            return cell
        }
        return ImageCollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: collectionViewWidth/2.0 - 15, height: collectionViewHeight/5 - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            imageForPass = ImageForPass(title: cell.infoLabel.text ?? "Title", image: cell.imageView.image ?? UIImage())
            performSegue(withIdentifier: "presentPopImageVC", sender: nil)
        }
        
    }
}

extension AlbumViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopImageVC else { return nil}
        popVC.imageToDisplay = cell.imageView.image
        popVC.imageTitle = cell.infoLabel.text
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

