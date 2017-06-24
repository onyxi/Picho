//
//  CamVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 08/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import FirebaseStorage

class CamVC: UIViewController, AVCapturePhotoCaptureDelegate, UpdateFilterDelegate, UpdateAlbumButtonDelegate, UIPopoverPresentationControllerDelegate, UploadMediaDelegate {


//   -------IB Outlets---------------------------
    @IBOutlet weak var selectedAlbumCover: UIImageView!
    @IBOutlet weak var selectAlbumBtn: UIButton!
    @IBOutlet weak var cameraPreviewFrame: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var selectFilterBtn: UIButton!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var albumPicsLabel: UILabel!
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var flashLayer: UIView!


//   -------Declare Variables---------------------------
    
    var currentUser: CurrentUser?
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer?

    var storageRef: FIRStorageReference!

  //  var activeInput: AVCaptureDeviceInput!
  //  let imageOutput = AVCaptureStillImageOutput()
  //  var captureDevice: AVCaptureDevice!

    var popoverIsDisplayed = false // flag to signal if popover currently being displayed

    // setup variables to hold Core Data objects
      // variable to hold current album object
    var currentAlbum: NSManagedObject?
      // variable to hold user as object to associate with new images
    var appUser: NSManagedObject!
      // number of photos left available for currently selected album
    var currentAlbumPhotosRemaining: Int?
    var currentAlbumPhotosTaken: Int?

      // var album: [NSManagedObject] = []
    
    var activeAlbums: [Album]?
    var currentlySelectedAlbum: Album?

//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [start storage config]
        storageRef = FIRStorage.storage().reference()
        // [end storage config]
        
        // hide camera flash indicator
        self.flashLayer.alpha = 0
        
        // get app user as NS object to associate with pictures
      //  let appUserArray = CoreDataModel.fetchUsers(named: "Pete Holdsworth")
       // appUser = appUserArray[0]

        /// set navigation controller title font
        //  self.navBar.titleTextAttributes = ([NSFontAttributeName: UIFont(name: "LobsterTwo-BoldItalic", size: 24)!, NSForegroundColorAttributeName: UIColor.white])
        
        /// set NavigationBar title as logo
        let titleLogo = UIImageView()
        titleLogo.image = UIImage(named: "logo")
        titleLogo.frame.size.width = 100
        titleLogo.frame.size.height = 30
        let logoOrigin = (self.view.bounds.width / 2) - 50
        titleLogo.frame.origin = CGPoint(x: logoOrigin, y: 25)
        self.navigationItem.titleView = titleLogo
        self.navBar.addSubview(titleLogo)
        
        /// set Album Button appearance
        selectedAlbumCover.layer.cornerRadius = 8
        selectedAlbumCover.clipsToBounds = true
        selectAlbumBtn.layer.cornerRadius = 8
        selectAlbumBtn.clipsToBounds = true
        albumLabel.text = "Travels 2016"
        albumPicsLabel.text = "27"
        albumCoverImage.image = UIImage(named: "palms3")
        
        //// configure 'choose filter' and 'choose album' button appearance
        /// set Filter Button appearance
        if let currentFilterName = UserDefaults.standard.string(forKey: "savedCurrentFilter") {
            updateFilterInfo(filterName: currentFilterName)
        }

        /// set Album Button appearance
      //  let allCurrentAlbums = CoreDataModel.fetchAlbums(isAvailable: false, source: nil, albumName: nil) // import available albums from Core Data
       
        
        /*
        for album in allCurrentAlbums {
            if album.value(forKey: "title") as? String == savedCurrentAlbumTitle {
                currentAlbum = album // search array for available album matching saved current album title
            }
        }
        
       
        let currentAlbumCover = currentAlbum?.value(forKey: "coverImage") as? NSManagedObject
        let currentAlbumCoverImage = currentAlbumCover?.value(forKey: "image") as? UIImage
        let currentAlbumTitle = currentAlbum?.value(forKey: "title") as? String
        let currentAlbumPicCount = currentAlbum?.value(forKey: "photosRemaining") as? Int
        */
       // updateAlbumInfo(name: currentAlbumTitle!, picCount: currentAlbumPicCount!, coverImageName: currentAlbumCoverImage!)
        
        
        ////// begin using camera feed ////////////////////////

        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentUser = CurrentUser()
        
//        let savedCurrentAlbumTitle = UserDefaults.standard.string(forKey: "savedCurrentAlbum")! as String // load name of last chosen album
        //        let savedCurrentAlbumArray = CoreDataModel.fetchAlbums(isAvailable: false, source: nil, albumName: savedCurrentAlbumTitle)
        activeAlbums = FBService().fetchLocalActiveAlbums()
        getCurrentlySelectedAlbum()
        
        //  let savedCurrentAlbum = savedCurrentAlbumArray[0]
      //  updateAlbumInfo(album: savedCurrentAlbum)
   //     currentAlbum = savedCurrentAlbum
        
        
        // [start camera!!!]
        //setupCaptureSession()
    }
    
    
    func getCurrentlySelectedAlbum() {
        let savedCurrentAlbumID = UserDefaults.standard.string(forKey: "savedCurrentAlbumID")! as String
        if activeAlbums != nil {
            for album in activeAlbums! {
                if album.albumID == savedCurrentAlbumID {
                    currentlySelectedAlbum = album
                }
            }
        }
    }
    
    func didUploadMedia() {
        print ("media uploaded to firebase")
    }
    
    
//   -------Methods---------------------------
    /// switch cameras - front/rear
    @IBAction func switchButtonPressed(_ sender: AnyObject) {
        /// switch cameras
    }
    
    /// set up camera session/inputs
    func setupCaptureSession() {
        
        
        stillImageOutput = AVCapturePhotoOutput()
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetMedium
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                // Configure the Live Preview here...
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 458)
                cameraPreviewFrame.layer.addSublayer(previewLayer!)
             //  previewLayer!.frame = cameraPreviewFrame.bounds
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                captureSession!.startRunning()
                
 
                
            }
        }
       
    }
    
    
    // begin take picture
    @IBAction func takePicturePressed(_ sender: Any) {
        if self.currentAlbumPhotosRemaining! > 0 {
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 160,
                kCVPixelBufferHeightKey as String: 160
            ]
            settings.previewPhotoFormat = previewFormat
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    // callBack from take picture
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            print ("saving image to album")
//            CoreDataModel.saveImage(image: image, imageCreatedDate: Date(), owner: appUser, album: currentAlbum!)
            
            
            currentAlbumPhotosRemaining! -= 1
            currentAlbumPhotosTaken! += 1
            //CoreDataModel.updateAlbumInfo(album: currentAlbum!, date: nil, photosRemaining: currentAlbumPhotosRemaining, photosTaken: currentAlbumPhotosTaken)
            //updateAlbumButton(album: currentAlbum!)
            flashCameraPreview()
            
            
            // firebase upload
            
            // prepare info to upload
//            let albumName = currentAlbum?.value(forKey: "title") as! String
//            let photoNumberString = String(describing: currentAlbumPhotosTaken!)
//            let photoName = "photo: \(photoNumberString)"
//            let photo = image
//            FireSD.uploadPhotoFromMemory(albumName: albumName, photoName: photoName, photo: photo)
    
            // new 
//            let destinationAlbum = currentlySelectedAlbum
//            let media = image
            
            if currentlySelectedAlbum != nil {
                let fbService = FBService()
                fbService.uploadMediaDelegate = self
                fbService.commitMediaToAlbum(media: image, album: currentlySelectedAlbum!)
            }
            
            
            
        } else {
            print("some error here")
        }
 
        
        
    }

    // flash view finder to indicate picture taken
    func flashCameraPreview () {
        self.flashLayer.alpha = 0.7
        UIView.animate(withDuration: 0.5) {
            self.flashLayer.alpha = 0
        }
    }
    
    
    /// update Filter Button info with selection from ChooseFilterVC
    func updateFilterInfo (filterName: String) {
        filterLabel.text = filterName
    }
    
    /// update Album Button info with selection from ChooseAlbumVC
    func updateAlbumButton (album: Album) {
        //(name: String, picCount: Int, coverImageName: UIImage, ) {
        
//        if let name = album.value(forKey: "title") as? String {
//            albumLabel.text = name
//        }
        albumLabel.text = album.title
        
//        if let picsRemaining = album.value(forKey: "photosRemaining") as? Int {
//            albumPicsLabel.text = String(describing: picsRemaining)
//            self.currentAlbumPhotosRemaining = picsRemaining
//        }
        
        

        self.currentAlbumPhotosRemaining = 5
        albumPicsLabel.text = String(5)
        
//        if let picsTaken = album.value(forKey: "photosTaken") as? Int {
//            self.currentAlbumPhotosTaken = picsTaken
//        }
        
        var mediaCount = 0
        for contributor in album.contributors {
            if contributor.userID == currentUser?.userID {
                mediaCount += contributor.photosTaken
            }
        }
        self.currentAlbumPhotosTaken = mediaCount
        
//        if let coverImageObject = album.value(forKey: "coverImage") as? NSManagedObject {
//            if let coverImage = coverImageObject.value(forKey: "image") as? UIImage {
//                albumCoverImage.image = coverImage
//            }
//        }
        if let coverImage = album.coverImage {
            albumCoverImage.image = coverImage
        }
        

       // self.currentAlbum = album
        self.currentlySelectedAlbum = album
        
        /*
        if let selectedAlbumTitle = selectedAlbum.value(forKey: "title") as? String {
            if let selectedAlbumPicCount = selectedAlbum.value(forKey: "photosRemaining") as? Int {
                let selectedAlbumCover = selectedAlbum.value(forKey: "coverImage") as? NSManagedObject
                if let selectedAlbumImage = selectedAlbumCover?.value(forKey: "image") as? UIImage {
                    delegate?.updateAlbumInfo(name: selectedAlbumTitle, picCount: selectedAlbumPicCount, coverImageName: selectedAlbumImage)
                    UserDefaults.standard.set(selectedAlbumTitle, forKey: "savedCurrentAlbum")
                    /// update last-selected time
                    CoreDataModel.updateAlbumInfo(album: selectedAlbum)
                }
            }
        }
        */
        
        }

    

    
    /// show ChooseAlbumVC popover view controller
    @IBAction func selectAlbumBtnDidPressed(_ sender: AnyObject) {
        /// create instance of ChooseFilterVC
        let chooseAlbumVC = storyboard?.instantiateViewController(withIdentifier: "ChooseAlbumVC") as! ChooseAlbumVC
        
        /// allow dismissal of popover only popover currently displayed
        if popoverIsDisplayed {
            dismiss(animated: true, completion: nil)
        } else {
            popoverIsDisplayed = true
        }
        
        /// set up presentation controller
        chooseAlbumVC.modalPresentationStyle = .popover
        chooseAlbumVC.preferredContentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height - 226)
        chooseAlbumVC.view.backgroundColor = UIColor.clear
        if let popoverController = chooseAlbumVC.popoverPresentationController {
            popoverController.sourceView = selectAlbumBtn
            popoverController.sourceRect = selectAlbumBtn.bounds
            popoverController.permittedArrowDirections = .down
            popoverController.delegate = self
            
            var viewsToPass: [UIView]
            viewsToPass = [selectFilterBtn]
            popoverController.passthroughViews = viewsToPass
            
        }
        
        /// set destination view controller delegate
        chooseAlbumVC.updateAlbumButtonDelegate = self
        if self.activeAlbums != nil {
            chooseAlbumVC.activeAlbums = self.activeAlbums!
        }
        if self.currentlySelectedAlbum != nil {
            chooseAlbumVC.currentlySelectedAlbum = self.currentlySelectedAlbum
        }
        
        /// display ChooseAlbumVC
        present(chooseAlbumVC, animated: true, completion: nil)

    }

    
    /// show ChooseFilterVC popover view controller
    @IBAction func chooseFilterButtonPressed(_ sender: AnyObject) {
        
        /// create instance of ChooseFilterVC
        let chooseFilterVC = storyboard?.instantiateViewController(withIdentifier: "ChooseFilterVC") as! ChooseFilterVC
        
        /// allow dismissal of popover only popover currently displayed
        if popoverIsDisplayed {
            dismiss(animated: true, completion: nil)
        } else {
            popoverIsDisplayed = true
        }
        
        /// set up presentation controller
        chooseFilterVC.modalPresentationStyle = .popover
        chooseFilterVC.preferredContentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height - 228)
        chooseFilterVC.view.backgroundColor = UIColor.clear
        if let popoverController = chooseFilterVC.popoverPresentationController {
            popoverController.sourceView = selectFilterBtn
            popoverController.sourceRect = selectFilterBtn.bounds
            popoverController.permittedArrowDirections = .down
            popoverController.delegate = self
            var viewsToPass: [UIView]
            viewsToPass = [selectAlbumBtn]
            popoverController.passthroughViews = viewsToPass
    
        }
        
        /// set destination view controller delegate
        chooseFilterVC.delegate = self
        
        /// display chooseFilterVC
        present(chooseFilterVC, animated: true, completion: nil)

    }
    
    /// force popover style view controller presentation
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    

    /// set popover flag to false when popover is dismissed
    func popoverPresentationControllerDidDismissPopover(_: UIPopoverPresentationController) {
        popoverIsDisplayed = false
    }

//   -------General---------------------------

    
    /// set light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// hook for unwind segue
    @IBAction func unwindToCamVC(segue: UIStoryboardSegue) {}
    
}
