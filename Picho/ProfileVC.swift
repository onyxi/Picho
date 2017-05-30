//
//  ProfileVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 28/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    
//   -------IB Outlets---------------------------
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!

    
    
//   -------Declare Variables---------------------------
    var imagePicker: UIImagePickerController!
    
    var delegate: GoToPicsVCDelegate?
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// set profile picture image and appearance
        
        /// [START Get profile]
       
 // remove!!
 //             let fetchedUser = CoreDataModel.fetchUsers(named: "Pete Holdsworth")
 //             let profilePicImage = fetchedUser[0].value(forKey: "profileImage") as? UIImage
 //             profilePic.image = profilePicImage
        
        
        
        
//        let uid = UserDefaults.standard.value(forKey: "currentUserID")!
//        
//        DataService.instance.mainDBRef.child("users").child("\(uid)").child("profile").observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
//            print ("Snap: \(snapshot.debugDescription)")
//            
//            if let userProfile = snapshot.value as? Dictionary<String, AnyObject> {
//                if let profilePicURL = userProfile["profilePicURL"] as? String {
//                    //print (profilePicURL)
//                    // get image from dataservice
//                    //let image = DataService.instance.downloadImageFromStorageURL(url: profilePicURL)
//                    //print (image)
//                    
//                    let httpsReference = FIRStorage.storage().reference(forURL: profilePicURL)
//                    httpsReference.data(withMaxSize: 1 * 1024 * 1024) { (data: Data?, error: Error?) in
//                        if let error = error {
//                            print (error.localizedDescription)
//                        } else {
//                            let image = UIImage(data: data!)!
//                            print (image)
//                            self.profilePic.image = image
//                        }
//                    }
//                    
//                    
//                }
//            }
//        }
        
        
        /// [END Get Profile]
        
        profilePic.layer.cornerRadius = 47
        profilePic.clipsToBounds = true
        
        /// configure imagePicker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        /// configure usernameTextField
        usernameTextField.delegate = self
        let username = UserDefaults.standard.value(forKey: "username") as? String
        usernameTextField.text = username
        
        /// set up tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        /// set up swipe-down gesture
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ProfileVC.respondToSwipeDownGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        
        
        
        ///// test firebase download ///
        
        
     //   DataService.instance.profileMediaStorageRef
        
        
        
        ////////////////////////////////
    }
    

//   -------Methods---------------------------
    
    /// respond to swipe-down gesture
    func respondToSwipeDownGesture () {
        self.performSegue(withIdentifier: "unwindToNotesVC", sender: self)
    }

    /// select image when profile picture pressed
    @IBAction func profilePicButtonPressed(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    /// set profile picture to selection from imagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePic.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    /// unwind segue or dismiss when back button pressed
    @IBAction func doneButtonDidPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "unwindToNotesVC", sender: self)
        // or dismiss??
    }
    
    /// sign user out of Firebase
    @IBAction func signOutDidPressed(_ sender: Any) {
        
        do {
            try  FIRAuth.auth()?.signOut()
            
            DataService().signOutLocal()
            print ("signed out")
            self.dismiss(animated: true, completion: nil)
            delegate?.goToPicsVC()
          //  performSegue(withIdentifier: "SignOutToLogin", sender: nil)
        } catch {
            print ("could not sign out")
        }
        
    }
    
    
    
//   -------General---------------------------
    
    /// tap dismiss keyboard
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    /// dismiss keyboard when return key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
}
