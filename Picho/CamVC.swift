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

class CamVC: UIViewController, AVCapturePhotoCaptureDelegate, UpdateFilterButtonDelegate, UpdateAlbumButtonDelegate, UIPopoverPresentationControllerDelegate, CommitMediaDelegate {


//   -------IB Outlets---------------------------

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
    let constants = Constants()
    let dataService = DataService()
    var currentUser: CurrentUser?
    
    var selectedFilter: Filter?
    var selectedAlbum: Album?
    
    var selectedAlbumPhotosRemaining: Int?
    var selectedAlbumPhotosTaken: Int?
    
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer?


    var popoverIsDisplayed = false // flag to signal if popover currently being displayed

//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide camera flash indicator
        self.flashLayer.alpha = 0
        
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
        albumCoverImage.layer.cornerRadius = 8
        albumCoverImage.clipsToBounds = true
        selectAlbumBtn.layer.cornerRadius = 8
        selectAlbumBtn.clipsToBounds = true
        albumLabel.text = "default"
        albumPicsLabel.text = "0"
        albumCoverImage.image = UIImage(named: "default")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load Current User data
        currentUser = CurrentUser()
        
        //// get currently selected Album and update UI
        updateAlbumButton()
        
        /// get currently selected Filter and update UI
        updateFilterButton()
        
        // [start camera!!!]
        //setupCaptureSession()
    }
    
    
    //   -------Methods---------------------------

    
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
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                captureSession!.startRunning()
        
            }
        }
    }
    
    
    // begin take picture
    @IBAction func takePicturePressed(_ sender: Any) {
        if self.selectedAlbumPhotosRemaining! > 0 {
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
            
            flashCameraPreview()
            print ("saving image to album")
            // implement saving image here...
 //           dataService.commitMediaToAlbum(media: image, album: selectedAlbum)
 //           selectedAlbumPhotosRemaining -= 1
 //           selectedAlbumPhotosTaken +- 1
 //           updateAlbumButton()
            
        } else {
            print("some error here")
        }
 
        
        
    }
    
    func didCommitMedia() {
        print ("media committed")
        // implement resuming of app
    }
    
    /// switch cameras - front/rear
    @IBAction func switchButtonPressed(_ sender: AnyObject) {
        /// switch cameras
    }

    // momentarily flash the view preview to indicate picture taken
    func flashCameraPreview () {
        self.flashLayer.alpha = 0.7
        UIView.animate(withDuration: 0.5) {
            self.flashLayer.alpha = 0
        }
    }
    
    /// update Filter Button info with current filter data
    func updateFilterButton() {
        
        if let currentlySelectedFilter = UserDefaults.standard.string(forKey: self.constants.CURRENTFILTERID) {
            let selectedFiltersArray = dataService.fetchFilters(filterID: currentlySelectedFilter)
            if selectedFiltersArray.count > 0 {
                selectedFilter = selectedFiltersArray[0]
            }
            
        } else {
            // implement default filter selection...
            let selectedFiltersArray = dataService.fetchFilters(filterID: nil)
            if selectedFiltersArray.count > 0 {
                selectedFilter = selectedFiltersArray[0]
            }
            
        }
        
        filterLabel.text = selectedFilter?.name
    
    }
    
    /// update Album Button info with current album data
    func updateAlbumButton() {
        
        if let currentlySelectedAlbum = UserDefaults.standard.string(forKey: self.constants.CURRENTACTIVEALBUMID) {
            if let selectedAlbumsArray = dataService.fetchLocalActiveAlbums(albumID: currentlySelectedAlbum) {
                if selectedAlbumsArray.count > 0 {
                    selectedAlbum = selectedAlbumsArray[0]
                }
            }
        } else {
            // implement default album selection...
            if let selectedAlbumsArray = dataService.fetchLocalActiveAlbums(albumID: nil) {
                if selectedAlbumsArray.count > 0 {
                    selectedAlbum = selectedAlbumsArray[0]
                }
            }
        }
        
        albumLabel.text = selectedAlbum?.title
        albumCoverImage.image = selectedAlbum?.coverImage
        if let mediaRemaining = selectedAlbum?.userMediaRemaining() {
            albumPicsLabel.text = String(describing: mediaRemaining)
        }
        
    }

    
    /// show ChooseAlbumVC popover view controller
    @IBAction func chooseAlbumBtnDidPressed(_ sender: AnyObject) {
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
        chooseFilterVC.updateFilterButtonDelegate = self
        
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
