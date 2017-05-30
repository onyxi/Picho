//
//  AlbumPicsGalleryVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 27/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import CoreData

protocol UnwindFromDeletingAlbumDelegate {
    func unwindFromDeletingAlbum()
}


let albumImagesCache = NSCache<AnyObject, AnyObject>()

class AlbumPicsGalleryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, UpdateGalleryLocationDelegate, AlbumDetailsButtonDelegate, UnwindFromDeletingAlbumDelegate, FetchAlbumMediaDelegate, DeleteAlbumDelegate {

    
//   -------IB Outlets---------------------------
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
   

//   -------Declare Variables---------------------------
    // create arrays to hold objects from Core Data
    var coverImages: [NSManagedObject] = []
    var images: [NSManagedObject] = []
    var users: [NSManagedObject] = []
    
    var albumCover: UIImage?
    var albumMedia: [Media] = []
    
    var numberOfLoadedItems = 1
    
    var updateAlbumCollectionDelegate : UpdateAlbumCollectionDelegate?
    
    
    // recieve album object from previous View Controller
    private var _selectedAlbum: Album?
    var selectedAlbum: Album {
        get {
            return _selectedAlbum!
        } set {
            _selectedAlbum = newValue
        }
    }
    
//    private var _selectedAlbum: NSManagedObject?
//    var selectedAlbum: NSManagedObject {
//        get {
//            return _selectedAlbum!
//        } set {
//            _selectedAlbum = newValue
//        }
//    }
    
    
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// set up swipe-down gesture
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(AlbumPicsGalleryVC.respondToSwipeDownGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        // import cover image
        //let albumCoverImage = CoreDataModel.fetchCoverImages(isAvailable: nil, album: self._selectedAlbum)
        
        
        
        let fbService = FBService()
        fbService.fetchAlbumMediaDelegate = self
        //fbService.fetchAlbumMedia(albumID: selectedAlbum.albumID, mediaCount: selectedAlbum.mediaCount)
        print(selectedAlbum)
        fbService.fetchAlbumMedia(album: selectedAlbum)
        
        // import album images collection
//        self.coverImages.append(albumCoverImage[0])
//        let albumImages = CoreDataModel.fetchImages(album: self._selectedAlbum!)
//        for image in albumImages {
//            self.images.append(image)
//            if let imageOwner = image.value(forKey: "owner") as? NSManagedObject {
//                self.users.append(imageOwner)
//            }
//        }
        
        
        // set navigation bar title to album title
        //self.navigationItem.title = _selectedAlbum?.value(forKey: "title") as? String
        self.navigationItem.title = selectedAlbum.title
        
    }

    
    
    
//   -------Methods---------------------------
    
    // passes request from album details VC to dismiss current gallery and Pics VC to update collection view
    func unwindFromDeletingAlbum() {
        unwindAndUpdateCollectionView()
    }
    
    func unwind() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // dismiss current gallery and tell Pics VC to update collection view
    func unwindAndUpdateCollectionView () {
        unwind()
        updateAlbumCollectionDelegate?.updateAlbumCollection()
    }
    
    
    /// respond to swipe-down gesture
    func respondToSwipeDownGesture () {
        unwind()
    }
    
    
    // recieve fetched Album Media
    func didFetchAlbumMedia(fetchedMedia: [Media]) {
        albumMedia = fetchedMedia
        numberOfLoadedItems = fetchedMedia.count + 1
        collectionView.reloadData()
    }
    
    /// unwind when back button pressed
    @IBAction func backButtonDidPressed(_ sender: AnyObject) {
        albumImagesCache.removeAllObjects()
        self.dismiss(animated: true, completion: nil) 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    /// go to album collection view when bar button item pressed
    @IBAction func goToCollectionViewButtonPressed(_ sender: AnyObject) {
        let GalleryCollectionVC = storyboard?.instantiateViewController(withIdentifier: "GalleryCollectionVC") as! GalleryCollectionVC
        GalleryCollectionVC.delegate = self
       // GalleryCollectionVC.currentAlbum = self.images
        GalleryCollectionVC.albumMedia = albumMedia
        self.navigationController?.pushViewController(GalleryCollectionVC, animated: true)
    }
    
    
    /// collection view and contents
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //let albumAvailability = self._selectedAlbum?.value(forKey: "isAvailable") as! Bool

////////////////////////////
///!! testing code - remove dashes
    //    if albumAvailability == true {
            //return images.count + 1
        return numberOfLoadedItems
            //selectedAlbum.mediaCount + 1
   //     } else {
   //         return 1
   //     }
    }
    
    // configure size of items in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.bounds.width
        let cellHeight = self.collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // configure items in collection view
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // configure album cover cell
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCoverCollectionViewCell", for: indexPath) as! GalleryCoverCollectionViewCell
            
            cell.albumCoverImageView.isHidden = true
            
            // set album cover cell delegate to this View Controller
            cell.delegate = self
            
            
            // start activity indicator
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = cell.albumCoverImageView.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .gray
            cell.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            
            
            // display availabe date
            //if let availableDate = self._selectedAlbum?.value(forKey: "dateAvailable") {
            let dateFmt = DateFormatter()
            dateFmt.dateStyle = .long
            //let formattedDateStr = dateFmt.string(from: availableDate as! Date)
            let formattedDateStr = dateFmt.string(from: selectedAlbum.availableDate)
            cell.albumCoverAvailableDate.text = formattedDateStr
            //}
            
            // display number of image in album
            //let  imageCount = images.count //- 1
            var imageCount: Int {
                var mediaCount = 0
                for contributor in selectedAlbum.contributors {
                    mediaCount += contributor.photosTaken
                }
                return mediaCount
            }
            cell.albumCoverImageCount.text = String(imageCount)
            
            // display album description
            //            if let albumDescription = self._selectedAlbum?.value(forKey: "albumDescription") as? String {
            //                cell.albumCoverDescription.text = albumDescription
            //            }
            cell.albumCoverDescription.text = selectedAlbum.description
            
            
            // display cover image
//            if let coverImage = self.coverImages[0].value(forKey: "image") as? UIImage {
//                cell.albumCoverImageView.image = coverImage
//            }
    
            let urlString = selectedAlbum.coverURL
            
            if let cachedImage = albumImagesCache.object(forKey: selectedAlbum.albumID as AnyObject) as? UIImage {
                cell.albumCoverImageView.image = cachedImage
                cell.albumCoverImageView.isHidden = false
                self.albumCover = cachedImage
                activityIndicator.stopAnimating()
                return cell
            }
            
            
            if let cover = selectedAlbum.coverImage {
                albumImagesCache.setObject(cover, forKey: selectedAlbum.albumID as AnyObject)
                cell.albumCoverImageView.image = cover
                cell.albumCoverImageView.isHidden = false
                self.albumCover = cover
                activityIndicator.stopAnimating()
            } else {
                let coverURL = NSURL(string: urlString!)
                var request = URLRequest(url: coverURL as! URL)
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    //download hit an error so let's return out
                    if error != nil {
                        print (error)
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        if let downloadedImage = UIImage(data: data!) {
                            albumImagesCache.setObject(downloadedImage, forKey: self.selectedAlbum.albumID as AnyObject)
                            cell.albumCoverImageView.image = downloadedImage
                            cell.albumCoverImageView.isHidden = false
                            self.albumCover = downloadedImage
                            activityIndicator.stopAnimating()
                        }
                    })
                }
                task.resume()
            }
            
            
           
            
            return cell
            
        } else {
            
            // configure normal image cells
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryMainCollectionViewCell", for: indexPath) as! GalleryMainCollectionViewCell
            
            cell.itemPicture.isHidden = true
            
            let currentMediaItem = albumMedia[indexPath.row - 1]
            
            // start activity indicator
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = cell.itemPicture.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .gray
            cell.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            
            
            // display image
//            if let itemPictureImage: UIImage = images[indexPath.row - 1].value(forKey: "image") as? UIImage {
//                cell.itemPicture.image = itemPictureImage
//            }
            
            let pictureNumber: Int = indexPath.row
            cell.itemNumberLabel.text = "#\(pictureNumber)" // display image number in album
            //if let pictureDate: Date = images[indexPath.row - 1].value(forKey: "dateCreated") as? Date {
            let dateFmt = DateFormatter()
            dateFmt.dateStyle = .short
            //let formattedDateStr = dateFmt.string(from: pictureDate)
            let formattedDateStr = dateFmt.string(from: currentMediaItem.createdDate)
            cell.itemDateLabel.text = formattedDateStr // display date image was added
            //}
            
            //            if let pictureOwner: String = users[indexPath.row - 1].value(forKey: "name") as? String {
            //                cell.itemUsernameLabel.text = pictureOwner
            //            }
            
            cell.itemUsernameLabel.text = currentMediaItem.ownerUsername
            
            
            if currentMediaItem.mediaURL != nil {
                if let cachedImage = albumImagesCache.object(forKey: currentMediaItem.mediaURL as AnyObject) as? UIImage {
                    cell.itemPicture.image = cachedImage
                    cell.itemPicture.isHidden = false
                    activityIndicator.stopAnimating()
                    return cell
                }
            }
            
            
            if let image = currentMediaItem.image {
                // use the retrieved image
                albumImagesCache.setObject(image, forKey: currentMediaItem.mediaURL as AnyObject)
                cell.itemPicture.image = image
                cell.itemPicture.isHidden = false
                activityIndicator.stopAnimating()

            } else {
                // use the image url
                if currentMediaItem.mediaURL != nil {
                    let imageURL = NSURL(string: currentMediaItem.mediaURL!)
                    var request = URLRequest(url: imageURL as! URL)
                    
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        //download hit an error so let's return out
                        if error != nil {
                            print (error)
                            return
                        }
                        
                        DispatchQueue.main.async(execute: {
                            if let downloadedImage = UIImage(data: data!) {
                                albumImagesCache.setObject(downloadedImage, forKey: currentMediaItem.mediaURL as AnyObject)
                                cell.itemPicture.image = downloadedImage
                                cell.itemPicture.isHidden = false
                                activityIndicator.stopAnimating()
                                
                            }
                        })
                    }
                    task.resume()
                    
                    
                }
            }
            
            return cell
        }
    
    }
    
    
    
    
    // display current album's details
    func albumDetailsButtonPressed() {
        
        /// create instance of newAlbumVC
        let albumDetailsVC = storyboard?.instantiateViewController(withIdentifier: "AlbumDetailsVC") as! AlbumDetailsVC
        
    //    let destinationVC = segue.destination as! NewAlbumVC
    //    if let album = sender as? NSManagedObject {
    //        destinationVC.selectedAlbum = album
    //    }
        
        /// set up presentation controller
        albumDetailsVC.modalPresentationStyle = .popover
        albumDetailsVC.preferredContentSize = CGSize(width: 400, height: self.view.bounds.height - 15)
        if let popoverController = albumDetailsVC.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(origin: CGPoint(x: self.view.bounds.width - 37, y :self.view.bounds.height - 30), size: CGSize(width: 1, height: 1))
            popoverController.permittedArrowDirections = .down
            popoverController.delegate = self
        }

//        if let viewingAlbum = self._selectedAlbum {
//           // albumDetailsVC.selectedAlbum = viewingAlbum
//            albumDetailsVC.selectedAlbum = selectedAlbum
//        }
        guard let currentViewingAlbum = self._selectedAlbum else { return }
        guard let currentViewingAlbumCover = self.albumCover else { return }
        
        albumDetailsVC.selectedAlbum = currentViewingAlbum
        albumDetailsVC.albumCoverImage = currentViewingAlbumCover
        
        albumDetailsVC.unwindFromDeletingAlbumDelegate = self
        albumDetailsVC.deleteAlbumDelegate = self
        
        present(albumDetailsVC, animated: true, completion: nil)
        
    }
    
    func didDeleteAlbum() {
        unwind()
    }
    
    /// move scroll view to corresponding photo from selection in album collection view
    func updateGalleryLocation(newIndex: Int) {
        let indexPath = NSIndexPath.init(item: newIndex, section: 0)
        self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: false)
    }
    
    
//   -------General---------------------------
    
    /// hook for unwind from Gallery Collection View Controller segue
    @IBAction func unwindToAlbumPicsGalleryVC(segue: UIStoryboardSegue) {}
    
    /// force popover style view controller presentation
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}


