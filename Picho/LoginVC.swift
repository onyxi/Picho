//
//  ViewController.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 28/08/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

protocol LogInDelegate {
    func didLogIn()
}

import UIKit
import pop
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseAuth


class LoginVC: UIViewController, UITextFieldDelegate, AuthenticateDelegate {
    
    var logInDelegate: LogInDelegate?

//   -------IB Outlets---------------------------
    //// login with email object outlets
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    
    //// constraint outlets ////
    // screen set 1
    @IBOutlet weak var facebookBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailBtnConstraint: NSLayoutConstraint!
    // screen set 2
    @IBOutlet weak var emailFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var or2Constraint: NSLayoutConstraint!
    @IBOutlet weak var createAccountBtnConstraint: NSLayoutConstraint!
    
//   -------Declare Variables---------------------------
    // flag whether the user is on Email Log In screen or not
    var emailLoginScreen = false
    
    /// declare animation engine
    var animEngine: AnimationEngine!
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        /// assign text field delegates
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        /// initialise animation engine and pass in object constraints for handling
        self.animEngine = AnimationEngine(set1Constraints: [facebookBtnConstraint, googleBtnConstraint, emailBtnConstraint], set2Constraints: [emailFieldConstraint, passwordFieldConstraint, loginBtnConstraint, or2Constraint, createAccountBtnConstraint])
        
        /// set up swipe-right gesture for navigating back from the email log in screen to social media log in screen
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(LoginVC.backToSocialLogin(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        
        
        //// !!!!!!!!!!!!!! ////
        FIRMessaging.messaging().subscribe(toTopic: "/topics/news")
        
    }
    
//   -------Methods---------------------------
    /// initial animation of log in objects onto screen
    override func viewDidAppear(_ animated: Bool) {
        self.animEngine.animateLogInObjects(1, set1Destination: "centre", set2Destination: "right")
    }
    
    
    /// handle swipe gesture to return to social media log in screen
    func backToSocialLogin(_ gesture: UIGestureRecognizer) {
        if emailLoginScreen == true {
            self.animEngine.animateLogInObjects(0, set1Destination: "centre", set2Destination: "right")
        }
    }
    
    
    /// press Log in with Email button and animate to second log in screen & set screen flag to Email Log in
    @IBAction func logInWithEmailPressed(_ sender: AnyObject) {
        self.animEngine.animateLogInObjects(0.2, set1Destination: "left", set2Destination: "centre")
        emailLoginScreen = true
    }

    
    /// dismiss keyboard when area outside keyboard pressed
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// dismiss keyboard when return key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func showInvalidEntryAlert() {
        let alert = UIAlertController(title: "Username and Password required", message: "You must enter both a username and a password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    /// attempt log in to existing account
    @IBAction func loginDidPressed(_ sender: AnyObject) {
         if let email = emailField.text, let password = passwordField.text, (email.characters.count > 0 && password.characters.count > 0) {
            
            // call the sign-in service
            let fbService = DataService()
            fbService.authenticateDelegate = self
            fbService.signIn(email: email, password: password, onComplete: { (errMsg, data) in
                guard errMsg == nil else {
                    let alert = UIAlertController(title: "Authentication Error", message: errMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.dismiss(animated: true, completion: nil)
                //self.logInDelegate?.didLogIn()
            })
            
//            AuthService.instance.login(email: email, password: pass, onComplete: { (errMsg, data) in
//                guard errMsg == nil else {
//                    let alert = UIAlertController(title: "Authentication Error", message: errMsg, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//               // DataService.instance.getAndStoreLoggedInUserInfo(userID: data!.uid, loggingIn: true)
//                print (LoggedInUser.isLoaded)
//                // picsVC: check auth and fetch albums
//                self.dismiss(animated: true, completion: nil)
//            })
            
         } else {
            showInvalidEntryAlert()
        }
        
    }
    
    
    /// attempt create a new account
    @IBAction func createNewAccountDidPressed(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text, (email.characters.count > 0 && password.characters.count > 0) {
            
            // call the sign-up service
            let fbService = DataService()
            fbService.authenticateDelegate = self
            fbService.signUp(email: email, password: password, onComplete: { (errMsg, data) in
                guard errMsg == nil else {
                    let alert = UIAlertController(title: "Account Creation Error", message: errMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                // [START load default data to firebase database/storage bucket]
                
                    // once upload complete:
                    self.dismiss(animated: true, completion: nil)
                // [END load default data to firebase database/storage bucket]
                
              //self.logInDelegate?.didLogIn()
            })
            
//            // call the createAccount service
//            AuthService.instance.createAccount(email: email, password: pass, onComplete: { (errMsg, data) in
//                guard errMsg == nil else {
//                    let alert = UIAlertController(title: "Account Creation Error", message: errMsg, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//                self.dismiss(animated: true, completion: nil)
//            })
            
        } else {
            showInvalidEntryAlert()
        }
        
    }

    func didAuthenticate() {
        // call back to fetch user data after user logged in
        print("did authenticate")
        self.logInDelegate?.didLogIn()
    }
    
    
    
    
//   -------General---------------------------
    
    /// hide status bar for login screen
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    
    
    

        
}

