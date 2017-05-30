//
//  GalleryCollectionVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 28/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

protocol UpdateGalleryLocationDelegate {
    func updateGalleryLocation (newIndex: Int)
}

var albumCollectionImagesCache = NSCache<AnyObject, AnyObject>()

import UIKit
import CoreData

class GalleryCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

//   -------IB Outlets---------------------------
    @IBOutlet weak var collectionView: UICollectionView!
  
    
//   -------Declare Variables---------------------------
    var delegate: UpdateGalleryLocationDelegate?
    
    var images: [NSManagedObject] = []
    
    
//    private var _currentAlbum: [NSManagedObject]?
//    
//    var currentAlbum: [NSManagedObject] {
//        get {
//         //   return _currentAlbum!
//            return images
//        } set {
//           // _currentAlbum = newValue
//            images = newValue
//        }
//    }
    
    var albumMedia: [Media] = []
    
//    var albumMedia: [Media] {
//        get {
//            
//        } set {
//            
//        }
//    }
    
    
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        
    //    self.images = _currentAlbum
        
        ///set up swipe-right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GalleryCollectionVC.respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
//   -------Methods---------------------------

    /// unwind when back button pressed
    @IBAction func backButtonDidPressed(_ sender: AnyObject) {
         self.performSegue(withIdentifier: "unwindToAlbumPicsGalleryVC", sender: self)
    }
    
    /// unwind to album
    func returnToPrevious() {
        self.performSegue(withIdentifier: "unwindToAlbumPicsGalleryVC", sender: self)
    }
    
    /// respond to swipe-right gesture
    func respondToSwipeGesture() {
        returnToPrevious() // unwind View Controller
    }
    
    /// set up collection view and
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.images.count
        return self.albumMedia.count
    }
    
    // set collection view cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.collectionView.bounds.width/3) - 6
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // configure collection view cells
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
            
            ///// set production images///
        
            //let imageForCell = self.images[indexPath.row].value(forKey: "image")
        
            //let imageForThumbnail = imageForCell.value(forKey: "image")
        
            let currentMediaItem = albumMedia[indexPath.row]
        
        
            if let cachedImage = albumCollectionImagesCache.object(forKey: currentMediaItem.mediaID as AnyObject) as? UIImage {
                cell.thumbnailImage.image = cachedImage
                cell.thumbnailImage.isHidden = false
                return cell
            }
        
        
        
            if let image = currentMediaItem.image {
                albumCollectionImagesCache.setObject(image, forKey: currentMediaItem.mediaID as AnyObject)
                cell.thumbnailImage.image = image
                cell.thumbnailImage.isHidden = false
                
                return cell
            } else {
            
                
                guard let urlString = currentMediaItem.mediaURL else { return cell }
            
            let thumbnailURL = NSURL(string: urlString)

            var request = URLRequest(url: thumbnailURL as! URL)
        
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                //download hit an error so let's return out
                if error != nil {
                    print (error)
                    return
                }
            
                DispatchQueue.main.async(execute: {
                    if let downloadedImage = UIImage(data: data!) {
                        albumCollectionImagesCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        cell.thumbnailImage.image = downloadedImage
                        cell.thumbnailImage.isHidden = false
                    }
                })
            }
            task.resume()
        
            return cell
        }
    }
    

    /// when selection made - unwind and move album view to corresponding photo
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newPath = indexPath.row 
        delegate?.updateGalleryLocation(newIndex: newPath)
        
        returnToPrevious()
        
    }
    
//   -------General---------------------------
    
}
