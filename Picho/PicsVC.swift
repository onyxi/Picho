//
//  PicsVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 08/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth


protocol UpdateAlbumCollectionDelegate {
    func updateAlbumCollection()
}

protocol FetchUserDataDelegate {
    func fetchUserData()
}


let coverImageCache = NSCache<AnyObject, AnyObject>()


class PicsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate, FetchUserDataDelegate, UpdateAlbumCollectionDelegate, LogInDelegate, FetchAlbumsDelegate, UpdateAlbumDataDelegate {

//   -------IB Outlets---------------------------
    /// set component outlets
    @IBOutlet weak var leftArrows: UIImageView!
    @IBOutlet weak var rightArrows: UIImageView!
    @IBOutlet weak var pastAlbumsCollectionView: UICollectionView!
    @IBOutlet weak var futureAlbumsCollectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var newAlbumButton: UIBarButtonItem!
    @IBOutlet weak var pastIndicator: PicsPageIndicatorView!
    @IBOutlet weak var futureIndicator: PicsPageIndicatorView!
    
    // collection constraints
    @IBOutlet weak var pastCollectionXCon: NSLayoutConstraint!
    @IBOutlet weak var futureCollectionXCon: NSLayoutConstraint!
    
    
//   -------Declare Variables---------------------------
    
    var currentUser: CurrentUser?

    var picCollectionEngine: PicCollectionEngine!
    var currentAlbumSet = "past" // flag to signal past/future albums being displayed
    
    // setup arrays to hold objects from Core Data
    var pastAlbums: [NSManagedObject] = []
    var futureAlbums: [NSManagedObject] = []
    var pastCoverImages: [NSManagedObject] = []
    var futureCoverImages: [NSManagedObject] = []
    
    
    // setup Firebase data arrays
    var FBPastAlbums: [Album] = []
    var FBFutureAlbums: [Album] = []
   // var FBPastCoverImages: [UIImage] = []
   // var FBFutureCoverImages: [UIImage] = []
    
    
//   -------Main View Events---------------------------
    
    override func viewWillLayoutSubviews() {
     //   let pastAlbumsOrigin = 0 - (self.view.bounds.width/2)
       // pastAlbumsCollectionView.
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picCollectionEngine = PicCollectionEngine(pastCollectionX: pastCollectionXCon, futureCollectionX: futureCollectionXCon)
        
        /// set NavigationBar title as logo
        let titleLogo = UIImageView()
        titleLogo.image = UIImage(named: "logo")
        titleLogo.frame.size.width = 100
        titleLogo.frame.size.height = 30
        let logoOrigin = (self.view.bounds.width / 2) - 50
        titleLogo.frame.origin = CGPoint(x: logoOrigin, y: 25)
        self.navigationItem.titleView = titleLogo
        self.navBar.addSubview(titleLogo)
        
        /// set view controller delegates/datasources
        self.pastAlbumsCollectionView.delegate = self
        self.pastAlbumsCollectionView.dataSource = self
        self.futureAlbumsCollectionView.delegate = self
        self.futureAlbumsCollectionView.dataSource = self
        
        /// set up swipe-right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(PicsVC.respondToSwipeRightGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        /// set up swipe-left gesture
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(PicsVC.respondToSwipeLeftGesture))
        swipeRight.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        
        //// fetch data for collection view
//        self.pastAlbums = CoreDataModel.fetchAlbums(isAvailable: true, source: nil, albumName: nil)
//        self.futureAlbums = CoreDataModel.fetchAlbums(isAvailable: false,source: nil, albumName: nil)
//        self.pastCoverImages = CoreDataModel.fetchCoverImages(isAvailable: true, album: nil)
//        self.futureCoverImages = CoreDataModel.fetchCoverImages(isAvailable: false, album: nil)
        
        
        /// set up collection view indicators
        self.pastIndicator.isActive = true
        self.futureIndicator.isActive = false
        refreshIndicators()
        
        
        
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser == nil {
            clearAlbumData()
        }
        
        DispatchQueue.main.async {
           self.checkUserAuth()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // do 
    }
    
    
//   -------Methods---------------------------
    func respondToSwipeRightGesture () {
        switchCollectionViews(albumSet: "future")
    }

    func respondToSwipeLeftGesture () {
        switchCollectionViews(albumSet: "past")
    }
    
    /// set correctly highlighted arrows images to signal past/future albums
    func switchArrowImage (_ leftArrowsImage: String, rightArrowsImage: String) {
        self.leftArrows.image = UIImage(named: leftArrowsImage)
        self.rightArrows.image = UIImage(named: rightArrowsImage)
    }
    
    /// change collection view albums - past/future albums
    func switchCollectionViews (albumSet: String) {
        if albumSet == "past" {
            currentAlbumSet = "past" // set collectionView display flag
            switchArrowImage("arrowsLeftBlack", rightArrowsImage: "arrowsRight") // trigger switch of highlighted arrow icon
            pastIndicator.isActive = true
            futureIndicator.isActive = false
        } else {
            currentAlbumSet = "future" // set collectionView display flag
            switchArrowImage("arrowsLeft", rightArrowsImage: "arrowsRightBlack") // trigger switch of highlighted arrow icon
            pastIndicator.isActive = false
            futureIndicator.isActive = true
        }
        refreshIndicators()
        self.picCollectionEngine.switchViews(showView: albumSet)
    }
    
    /// user presses left-facing arrows
    @IBAction func leftArrowsDidPressed(_ sender: AnyObject) {
        switchCollectionViews(albumSet: "past")
        
    }
    
    /// user presses right-facing arrows
    @IBAction func rightArrowsDidPressed(_ sender: AnyObject) {
        switchCollectionViews(albumSet: "future")
    }
    
    
    /// show newAlbumVC popover view controller
    @IBAction func newAlbumButtonPressed(_ sender: AnyObject) {

        //// INITIATE POPOVER
    
        /// create instance of newAlbumVC
        let newAlbumVC = storyboard?.instantiateViewController(withIdentifier: "AlbumDetailsVC") as! AlbumDetailsVC
        
        /// set up presentation controller
        newAlbumVC.modalPresentationStyle = .popover
        newAlbumVC.preferredContentSize = CGSize(width: 400, height: self.view.bounds.height - 15)
        newAlbumVC.updateAlbumCollectionDelegate = self
        newAlbumVC.fetchUserDataDelegate = self
        
        
        if let popoverController = newAlbumVC.popoverPresentationController {
            popoverController.barButtonItem = newAlbumButton
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
        }
        
        
        /// display newAlbumVC
        present(newAlbumVC, animated: true, completion: nil)
    
        
    }

    
    func updateAlbumData() {
       fetchUserData()
    }
    
    
    func updateAlbumCollection() {
       // self.futureAlbums = CoreDataModel.fetchAlbums(isAvailable: false,source: nil, albumName: nil)
       // self.futureCoverImages = CoreDataModel.fetchCoverImages(isAvailable: false, album: nil)
        pastAlbumsCollectionView.reloadData()
        futureAlbumsCollectionView.reloadData()
        print ("update albums")
    }
    
    func refreshIndicators() {
        self.pastIndicator.setNeedsDisplay()
        self.futureIndicator.setNeedsDisplay()
    }
    
   
    

    
    func checkUserAuth () {
        // check if Firebase user currently authenticated
        if FIRAuth.auth()?.currentUser == nil {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            loginVC.logInDelegate = self
            present(loginVC, animated: true, completion: nil)
           //performSegue(withIdentifier: "LoginVC", sender: nil)
            return
        } else {
            // if user already logged in - fetch Firebase data
            print ("checkedAuth")
            fetchUserInfo()
        }
        
    }
    
    func didLogIn() {
        //
        print ("didLogIn")
        fetchUserInfo()
    }

    func fetchUserInfo() {
        
        fetchUserData()
    }
    
    func fetchUserData() {
       currentUser = CurrentUser()
//        let currentUser = CurrentUser(
//            userID: UserDefaults.standard.value(forKey: "currentUserID") as! String ,
//            username: UserDefaults.standard.value(forKey: "currentUsername") as! String,
//            email: UserDefaults.standard.value(forKey: "currentEmail") as! String,
//            profilePicURL: UserDefaults.standard.value(forKey: "currentProfilePicURL") as! String,
//            password: UserDefaults.standard.value(forKey: "currentPassword") as! String,
//            isLoaded: true
//        )
        
        let fbService = DataService()
        fbService.fetchAlbumsDelegate = self
        fbService.fetchFirebaseAlbums(user: currentUser!)
        
//        guard let userLoaded = LoggedInUser.isLoaded else { return }
//        if userLoaded {
//            guard let myUserID = LoggedInUser.myUserID else { return }
//            guard let myUsername = LoggedInUser.myUsername else { return }
//            guard let myEmail = LoggedInUser.myEmail else { return }
//            guard let myProfilePicURL = LoggedInUser.myProfilePicURL else { return }
//            let currentUser = User(userID: myUserID, username: myUsername, email: myEmail, profilePicURL: myProfilePicURL)
//            
////            let dataService = DataService()
////            dataService.fetchAlbumsDelegate = self
////            dataService.fetchAlbumData(user: loggedInUser)
//            
//            
//            /// Get future album data first from core data
//            
//            
//            print ("reached")
//            let fbService = FBService()
//            fbService.fetchAlbumsDelegate = self
//            fbService.fetchAlbumData(user: currentUser)
//            
//        } else {
//            print ("authenticated but no local user details")
//        }
    }
    
    
    // !! need to return album objects and album covers - as concurrent arrays. then cycle through and filter into past/future arrays
    func didFetchAlbumsData(pastAlbums: [Album], futureAlbums: [Album]) {
        FBPastAlbums = pastAlbums
        FBFutureAlbums = futureAlbums
        
        print ("data fetched:")
        print ("past...")
        for album in FBPastAlbums {
          //  print (album)
        }
        print ("future...")
        for album in FBFutureAlbums {
          //  print (album)
        }
        updateAlbumCollection()
    }
    
    
    func clearAlbumData() {
        FBPastAlbums.removeAll()
        FBFutureAlbums.removeAll()
        coverImageCache.removeAllObjects()
        updateAlbumCollection()
    }
    
//   -------General---------------------------
    
    // set number of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.pastAlbumsCollectionView {
            //return pastAlbums.count
            return FBPastAlbums.count
        } else{
            //return futureAlbums.count
            return FBFutureAlbums.count
        }
    }
    
    // set size of items in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (self.pastAlbumsCollectionView.bounds.width/3) - 4
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
    // configure cells for collection view
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // set cells for 'past/available' collection view
        if collectionView == self.pastAlbumsCollectionView {
            
            let cell = pastAlbumsCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath) as! PastAlbumCollectionViewCell
            cell.albumCoverImage.isHidden = true
            cell.albumTitleLabel.isHidden = true
            cell.shadeLayer.isHidden = true
            
        //    var imageForCell = UIImage(named: "rockiesCover") ///// use default 'no cover' image here
        //    var titleForCell = "No Title"
            
            //var currentAlbum = pastAlbums[indexPath.row]
            var currentAlbum = FBPastAlbums[indexPath.row]
            //var coverImages = self.pastCoverImages
            
         //   titleForCell = currentAlbum.value(forKey: "title") as! String
            cell.albumTitleLabel.text = currentAlbum.title
            
//            for image in coverImages {
//                if image.value(forKey: "album") as? NSManagedObject == currentAlbum {
//                    imageForCell = image.value(forKey: "image") as? UIImage
//                }
//            }
            
            let urlString = currentAlbum.coverURL
            
            if let cachedImage = coverImageCache.object(forKey: currentAlbum.albumID as AnyObject) as? UIImage {
                
                cell.albumCoverImage.image = cachedImage
                cell.albumCoverImage.isHidden = false
                cell.shadeLayer.isHidden = false
                cell.albumTitleLabel.isHidden = false
                return cell
            }
            
            let coverURL = NSURL(string: currentAlbum.coverURL!)
            var request = URLRequest(url: coverURL as! URL)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                //download hit an error so let's return out
                if error != nil {
                    print (error)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    if let downloadedImage = UIImage(data: data!) {
                        coverImageCache.setObject(downloadedImage, forKey: currentAlbum.albumID as AnyObject)
                        cell.albumCoverImage.image = UIImage(data: data!)
                        cell.albumCoverImage.isHidden = false
                        cell.shadeLayer.isHidden = false
                        cell.albumTitleLabel.isHidden = false
                    }
                    
                    
                })
                
                
            }
            task.resume()
            
            
            
            
           // cell.albumCoverImage.image = imageForCell
          //  cell.albumTitleLabel.text = titleForCell
            
            return cell
            
        } else {
            // set cells for 'future/not-available' collection view
            let cell = futureAlbumsCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath) as! FutureAlbumCollectionViewCell
            
            cell.albumCoverImage.isHidden = true
            cell.albumTitleLabel.isHidden = true
            cell.shadeLayer.isHidden = true
            cell.lockedIcon.isHidden = true
            
         //   var hasCoverImage = false
          //  var imageForCell = UIImage(named: "rockiesCover") ///// use default 'no cover' image here
           // var titleForCell = "No Title"
            
            //var currentAlbum = futureAlbums[indexPath.row]
            var currentAlbum = FBFutureAlbums[indexPath.row]
            //var coverImages = self.futureCoverImages
            
        //    titleForCell = currentAlbum.value(forKey: "title") as! String

            cell.albumTitleLabel.text = currentAlbum.title

          //  cell.albumCoverImage.loadImageUsingCacheWithURLString(url: currentAlbum.coverURL)
            
            let urlString = currentAlbum.coverURL
            
            if let cachedImage = coverImageCache.object(forKey: currentAlbum.albumID as AnyObject) as? UIImage {
                cell.albumCoverImage.image = cachedImage
                cell.albumCoverImage.isHidden = false
                cell.shadeLayer.isHidden = false
                cell.albumTitleLabel.isHidden = false
                cell.lockedIcon.isHidden = false
                return cell
            }
            
            if let cover = currentAlbum.coverImage {
                coverImageCache.setObject(cover, forKey: currentAlbum.albumID as AnyObject)
                cell.albumCoverImage.image = cover
                cell.albumCoverImage.isHidden = false
                cell.shadeLayer.isHidden = false
                cell.albumTitleLabel.isHidden = false
                cell.lockedIcon.isHidden = false
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
                            coverImageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                            cell.albumCoverImage.image = downloadedImage
                            cell.albumCoverImage.isHidden = false
                            cell.shadeLayer.isHidden = false
                            cell.albumTitleLabel.isHidden = false
                            cell.lockedIcon.isHidden = false
                        }
                    })
                    
                    
                }
                task.resume()
                
            }
            
            return cell
        }
    }

    
    
    
    // when item selected go to album
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //var didSelectAlbum: NSManagedObject?
        var didSelectAlbum: Album
        if currentAlbumSet == "past" {
            //didSelectAlbum = self.pastAlbums[indexPath.row]
            didSelectAlbum = self.FBPastAlbums[indexPath.row]
        } else {
            //didSelectAlbum = self.futureAlbums[indexPath.row]
            didSelectAlbum = self.FBFutureAlbums[indexPath.row]
        }
        
        performSegue(withIdentifier: "picsToAlbumSegue", sender: didSelectAlbum)
        
    }
    
    // prepare recieving View Controller to dsplay album relating to selected item
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("segue fired")
        if segue.identifier != "LoginVC" {
            let destinationNavVC = segue.destination as! UINavigationController
            //            if let destinationVC = destinationNavVC.topViewController as? AlbumDetailsVC {
            //                destinationVC.fetchUserDataDelegate = self
            //                print ("im album details vc")
            //            } else
            if let destinationVC = destinationNavVC.topViewController as? AlbumPicsGalleryVC? {
                destinationVC?.updateAlbumCollectionDelegate = self
                if let album = sender as? Album {
                    destinationVC?.selectedAlbum = album
                }
            }
        }
    }
    
    





    /// force popover style view controller presentation
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /// set light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// hook for unwind segue
    @IBAction func unwindToPicsVC(segue: UIStoryboardSegue) {}
    

}




