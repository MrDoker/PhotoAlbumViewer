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

class AlbumViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var toolBarForAlbum: UIToolbar!
    @IBOutlet weak var previousAlbumPageBarButton: UIBarButtonItem!
    @IBOutlet weak var nextAlbumPageBarButton: UIBarButtonItem!
    @IBOutlet weak var currentPageCounerBarItem: UIBarButtonItem!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    
    let refresh = UIRefreshControl()
    
    var currentAlbum = 0
    var albumsArray = [Album]()
    
    var imageForPass: ImageForPass?
    var lastUsedCellIndex = 0
    var isDataLoaded = false
    
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.2431372549, blue: 0.3294117647, alpha: 1)
        
        collectionView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        //for 3dTouch
        registerForPreviewing(with: self, sourceView: collectionView!)

        fetchData()
        
        //doubletap scroll to 10 rows ahead
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        doubleTap.delaysTouchesBegan = true
        view.addGestureRecognizer(doubleTap)
    }
    
    func configToolBar() {
        currentPageCounerBarItem.title = "Album: \(currentAlbum + 1) of \(albumsArray.count)"
        if currentAlbum == 0 {
            previousAlbumPageBarButton.isEnabled = false
        } else if currentAlbum == albumsArray.count-1 {
            nextAlbumPageBarButton.isEnabled = false
        } else {
            nextAlbumPageBarButton.isEnabled = true
            previousAlbumPageBarButton.isEnabled = true
        }
    }
    
    //MARK: FetchData
    func fetchData() {
        //reload all
        refresh.beginRefreshing()
        toolBarForAlbum.isHidden = true
        isDataLoaded = false
        self.activityIndicator.startAnimating()
        self.loadingStackView.isHidden = false
        currentAlbum = 0
        
        let dataService = DataService()
        dataService.fetchDataFromJSON { (albumsArray) in
            if let albumsArray = albumsArray {
                self.isDataLoaded = true
                self.albumsArray = albumsArray
                
                self.collectionView.reloadData()
                self.configToolBar()
                
                self.refresh.endRefreshing()
                self.toolBarForAlbum.isHidden = false
                self.activityIndicator.stopAnimating()
                self.loadingStackView.isHidden = true
            } else {
                print("Error: Cant Fetch Data From JSON")
                self.showError()
            }
        }
    }
    
    func showError() {
        let errorAlert = UIAlertController(title: "Somethig went wrong", message: "Check internet connection and try again or restart app", preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (_) in
            self.fetchData()
        }))
        present(errorAlert, animated: true, completion: nil)
    }
    
    @objc func handleDoubleTap() {
        if lastUsedCellIndex + 10 >= collectionView.numberOfItems(inSection: 0) {
            collectionView.scrollToItem(at: IndexPath(row: collectionView.numberOfItems(inSection: 0) - 1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        } else {
            collectionView.scrollToItem(at: IndexPath(row: lastUsedCellIndex + 10, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
    }
    
    @objc func handleRefresh() {
        ImageDownloadService.instance.imageCache.removeAllObjects()
        fetchData()
    }
    
    @IBAction func previousAlbumPageAction(_ sender: Any) {
        currentAlbum -= 1
        configToolBar()
        collectionView.reloadData()
    }
    
    @IBAction func nextAlbumPageAction(_ sender: Any) {
        currentAlbum += 1
        configToolBar()
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPopImageVC" {
            let popVC = segue.destination as? PopImageVC
            popVC?.imageTitle = imageForPass?.title
            popVC?.imageToDisplay = imageForPass?.image
        }
    }
}

//MARK: extension Collection Delegate and DataSource
extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isDataLoaded {
            return 0
        }
        return albumsArray[currentAlbum].images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        lastUsedCellIndex = indexPath.row
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ImageCollectionViewCell {
            cell.configCellFor(imageModel: albumsArray[currentAlbum].images[indexPath.row])
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

//MARK: extension for 3dTouch
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

//MARK: extension for Hiding Toolbar
extension AlbumViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y>0) {
            toolbarHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else if velocity.y < 0 {
            toolbarHeightConstraint.constant = 44
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
