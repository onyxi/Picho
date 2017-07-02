//
//  AlbumDetailsVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 29/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//


import UIKit
import CoreData

protocol UpdateAlbumDataDelegate {
    func updateAlbumData()
}

protocol DeleteAlbumDelegate {
    func didDeleteAlbum()
}

class AlbumDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UpdatingDateDelegate, UITextFieldDelegate, UITextViewDelegate, UploadAlbumDelegate, DeleteAlbumDelegate  {
    
    //   -------IB Outlets---------------------------
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerUsernameLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var albumPhotosLabel: UILabel!
    @IBOutlet weak var ownerPicsLabel: UILabel!
    @IBOutlet weak var addImageMainLabel: UILabel!
    var textViewPlaceholderLabel = UILabel()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var albumTitleTextField: CustomTextField!
    @IBOutlet weak var albumDescTextView: CustomTextView!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var addImageMainButton: UIButton!
    @IBOutlet weak var addImageSmallButton: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    
    //// hide these features when creating new album
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var pageSpacer1: UIView!
    @IBOutlet weak var pageSpacer2: UIView!

    
    
    //   -------Declare Variables---------------------------
    
    var currentUser: CurrentUser?
    
    var updateAlbumCollectionDelegate : UpdateAlbumCollectionDelegate?
    var unwindFromDeletingAlbumDelegate : UnwindFromDeletingAlbumDelegate?
    var updateAlbumDataDelegate: UpdateAlbumDataDelegate?
    var fetchUserDataDelegate: FetchUserDataDelegate?
    var deleteAlbumDelegate: DeleteAlbumDelegate?
    
    var albumName: String?
    var dateAvailable: Date?
    var createdDate: Date?
    var ownerID: String?
    var ownerUsername: String?
    var albumMediaCount = 0
    var contributors: [NSManagedObject] = []
    var ownerMediaCount = 0
    
    
    // instantiate dateFormatter and imagePicker
    let dateFormatter = DateFormatter()
    var imagePicker: UIImagePickerController!
    
    /////// recieve album object if accessed from existing album
//    private var _selectedAlbum: NSManagedObject?
//    var selectedAlbum: NSManagedObject {
// //   private var _selectedAlbum: Album?
// //   var selectedAlbum: Album {
//        get {
//            return _selectedAlbum!
//        } set {
//            _selectedAlbum = newValue
//        }
//    }
    
    private var _selectedAlbum: Album?
    var selectedAlbum: Album {
        get {
            return _selectedAlbum!
        } set {
            _selectedAlbum = newValue
        }
    }
    
   var albumCoverImage: UIImage?
//    var albumCoverImage: UIImage {
//        get {
//            return _albumCoverImage!
//        } set {
//            _albumCoverImage = newValue
//        }
//    }
    
    
    ///////////
    
    
    
    //   -------Main View Events---------------------------
    
    //// set smaller view controller frame size when creating a new album
    override func viewWillLayoutSubviews() {
        if self._selectedAlbum == nil {
            self.scrollView.contentSize = CGSize(width: 300, height: 624)
            self.scrollView.isDirectionalLockEnabled = true
            deleteButton.isHidden = true
            archiveButton.isHidden = true
            pageSpacer1.isHidden = true
            pageSpacer2.isHidden = true
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        /// import album object
        if _selectedAlbum == nil {
            albumName = "New Album"
            dateAvailable = Date()
            createdDate = Date()
            let userName = UserDefaults.standard.value(forKey: "username")
            ownerUsername = userName as! String?
            albumMediaCount = 0
            ownerMediaCount = 0
        } else {
            if let album = _selectedAlbum {
                //albumName = album?.value(forKey: "title") as? String
                albumName = album.title
                //dateAvailable = album?.value(forKey: "dateAvailable") as? Date
                dateAvailable = album.availableDate
                //createdDate = album?.value(forKey: "dateCreated") as? Date
                createdDate = album.createdDate
                //let userName = UserDefaults.standard.value(forKey: "username")
                //ownerUsername = userName as! String?
                ownerID = album.ownerID
                // !!!!!! owner username???
                //albumPhotos = album?.value(forKey: "photosTaken") as! Int
                var mediaCount = 0
                for contributor in album.contributors {
                    mediaCount += contributor.photosTaken
                }
                albumMediaCount = mediaCount
                //ownerPics = album?.value(forKey: "photosRemaining") as! Int
                //ownerPics = album.mediaCount
                ownerMediaCount = album.ownerMediaCount()
                //let coverImageObjectsArray = CoreDataModel.fetchCoverImages(isAvailable: nil, album: _selectedAlbum)
                //let coverImage = coverImageObjectsArray[0].value(forKey: "image") as? UIImage
                //albumCoverImage = coverImage
                
                //// !!!!!  rushed album details population!!!!
                self.navBarTitle.title = albumName
                addImageMainButton.isHidden = true
                addImageMainLabel.isHidden = true
                albumTitleTextField.text = albumName
                //albumDescTextView.text = album?.value(forKey: "albumDescription") as? String
                albumDescTextView.text = album.description
            }
            
        }
        
        /// set album details
        
        dateFormatter.dateStyle = .long
        if dateAvailable != nil {
            let availableDateStr = dateFormatter.string(from: dateAvailable!)
            dateLabel.text = "Date Available: \(availableDateStr)"
        }
        
        dateFormatter.dateStyle = .short
        if createdDate != nil {
            let createdDateStr = dateFormatter.string(from: createdDate!)
            createdDateLabel.text = createdDateStr
        }
        
        if ownerUsername != nil {
            ownerUsernameLabel.text = ownerUsername
        }
        
        albumPhotosLabel.text = String(describing: albumMediaCount)
        
        ownerPicsLabel.text = String(describing: ownerMediaCount)
        
        if albumCoverImage != nil {
            albumCover.image = albumCoverImage
        }
        
        
        
        
        
        /*
         /// import user object
         let albumContributors = CoreDataModel.fetchUsers(named: "Pete Holdsworth")
         contributors = albumContributors
         */
        
        
        
        
        
        // create Text Area placeholder label programatically
        if _selectedAlbum == nil {
            let placeholderX: CGFloat = 5
            let placeholderY: CGFloat = 5
            let placeholderWidth = albumDescTextView.frame.size.width - placeholderX
            let placeholderHeight: CGFloat = 20
            let placeholderFontSize: CGFloat = 15 // self.view.frame.size.width / 25
            
            textViewPlaceholderLabel.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
            textViewPlaceholderLabel.text = "Album description..."
            textViewPlaceholderLabel.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
            textViewPlaceholderLabel.textColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
            textViewPlaceholderLabel.textAlignment = .left
            albumDescTextView.addSubview(textViewPlaceholderLabel)
        }
        
        // hide small 'addImage' button
        addImageSmallButton.isHidden = true
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        albumTitleTextField.delegate = self
        albumDescTextView.delegate = self
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentUser = CurrentUser()
    }
    
    
    //   -------Methods---------------------------
    @IBAction func backButtonPressed(_ sender: Any) {
        unwind()
    }
    
    
    
    func unwindAndUpdateCollectionView () {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        //if self._selectedAlbum != nil {
            //CoreDataModel.deleteAlbum(album: self._selectedAlbum!)
        
            
        //    unwindFromDeletingAlbumDelegate?.unwindFromDeletingAlbum()
        //    self.dismiss(animated: true, completion: nil)
            
       // }
        
        if let viewingAlbum = _selectedAlbum {
            let fbService = DataService()
            fbService.deleteAlbumDelegate = self
            fbService.deleteAlbum(album: viewingAlbum)
        }
    }
    
    func didDeleteAlbum() {
        self.deleteAlbumDelegate?.didDeleteAlbum()
        unwind()
    }
    
    // dismiss popover VC
    func unwind () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    /// unwind when done button pressed RENAME???
    @IBAction func doneButtonDidPressed(_ sender: AnyObject) {
        if self._selectedAlbum == nil {
            
            // set album data for save
            guard let albumTitle = albumTitleTextField.text else { return }
            guard let albumDescription = albumDescTextView.text else { return }
            guard let dateAvailable = self.dateAvailable else { return }
            guard let coverImage = self.albumCover.image else { return }
            
            // set owner's details as first contributor
//            guard let albumOwnerID = CurrentUser.myUserID else { return }
//            guard let albumOwnerUsername = CurrentUser.myUsername else { return }
            guard let albumOwnerID = currentUser?.userID else { return }
            guard let albumOwnerUsername = currentUser?.username else { return }
            
            
            var contributorsList: [Contributor] = []
            let owner = Contributor(userID: albumOwnerID, username: albumOwnerUsername, photosRemaining: ownerMediaCount, photosTaken: ownerMediaCount)
            contributorsList.append(owner)
            
            let newAlbum = Album(albumID: "", ownerID: albumOwnerID, title: albumTitle, description: albumDescription, createdDate: Date(), availableDate: dateAvailable, contributors: contributorsList, coverURL: nil, coverImage: coverImage, isActive: true)
            
            let fbService = DataService()
            fbService.uploadAlbumDelegate = self
            //fbService.createNewAlbum(title: albumTitle, description: albumDescription, availableDate: dateAvailable, coverImage: coverImage, contributors: contributorsList)
            fbService.createNewAlbum(album: newAlbum)
            
//            // set album data for save
//            var albumTitle = ""
//            if albumTitleTextField.text != nil {
//                albumTitle = albumTitleTextField.text!
//            }
//            var albumDescription = ""
//            if albumDescTextView.text != nil {
//                albumDescription = albumDescTextView.text
//            }
//            var owner = ""
//            if let username = LoggedInUser.myUsername {
//                owner = username
//            }
            //let userName = UserDefaults.standard.value(forKey: "username") as! String
//            if let userName = LoggedInUser.myUsername
//            owner = userName
            
//            var dateCreated = Date()
//            if self.createdDate != nil {
//                dateCreated = self.createdDate!
//            }
//            var dateAvailable = Date()
//            if self.dateAvailable != nil {
//                dateAvailable = self.dateAvailable!
//            }
            
            /// save
//            CoreDataModel.saveAlbum(title: albumTitle, albumDescription: albumDescription, owner: owner, dateCreated: dateCreated, dateAvailable: dateAvailable, isAvailable: false, photosTaken: self.albumMediaCount, photosRemaining: self.ownerMediaCount, lastSelected: Date())
//            UserDefaults.standard.set(albumTitle, forKey: "savedCurrentAlbum")
//            
//            var coverImage: UIImage
//            if self.albumCoverImage != nil {
//                coverImage = self.albumCoverImage!
//            } else {
//                coverImage = UIImage(named: "rockiesCover")! ////// ADD DEFAULT OVER IMAGE HERE
//            }
//            CoreDataModel.saveCoverImage(image: coverImage, albumName: albumTitle)
            
        }
        
        
        
    }
    
    func didUploadAlbum() {
        print ("album uploaded")
        self.fetchUserDataDelegate?.fetchUserData()
        self.dismiss(animated: true, completion: nil)
        //unwindAndUpdateCollectionView()
    }
    
    func unwindAndRefresh() {
        self.fetchUserDataDelegate?.fetchUserData()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    /// show DatePicker popover view controller
    @IBAction func datePopover(_ sender: AnyObject) {
        /// create instance of DatePicker view controller
        let datePickerViewController = storyboard?.instantiateViewController(withIdentifier: "datePickerVC") as! DatePickerPopoverVC
        
        /// set popover's delegate to self (to pass data through protocol)
        datePickerViewController.delegate = self
        
        /// Set up DatePicker view controller
        datePickerViewController.modalPresentationStyle = .popover
        datePickerViewController.preferredContentSize = CGSize(width: 320, height: 200)
        if let popoverController = datePickerViewController.popoverPresentationController {
            popoverController.sourceView = dateLabel as! UIView
            popoverController.sourceRect = dateLabel.bounds
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
        }
        
        /// display popover
        present(datePickerViewController, animated: true, completion: nil)
        
    }
    
    /// force popover presentation view style
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    
    /// update date label text with new value from date picker
    func updateDateLabel(newDate: Date){
        self.dateAvailable = newDate
        dateFormatter.dateStyle = .long
        let strDate = dateFormatter.string(from: newDate)
        dateLabel.text = "Date Available: \(strDate)"
        
        
    }
    
    /// update label with allocated pics to owner
    @IBAction func addPicsDidPressed(_ sender: AnyObject) {
        ownerMediaCount += 1
        ownerPicsLabel.text = String(ownerMediaCount)
    }
    
    /// update album cover image with picture selected from camera roll and reconfig album cover - ADD TAKE PHOTO??
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            albumCover.contentMode = .scaleAspectFill
            albumCover.image = pickedImage
            addImageMainLabel.isHidden = true
            addImageMainButton.isHidden = true
            addImageSmallButton.isHidden = false
            self.albumCoverImage = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// when album cover tapped, launch image picker to select from camera roll
    @IBAction func addImage(sender: AnyObject!){
        present(imagePicker, animated: true, completion: nil)
    }
    
    /// hide textView placeholder when user starts typing
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceholderLabel.isHidden = true
    }
    
    
    //   -------General---------------------------
    
    /// tap dismiss keyboard
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y:  150), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    
    /// dismiss keyboard when return key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// dismiss keyboard when 'return' pressed while editing textView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    /// move scroll view to make room for keyboard appearing
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0,y:  225), animated: true)
    } /// return scroll view when keyboard disappears
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    
}
