//
//  ViewController.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 28/08/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import pop

class LoginVC: UIViewController, UITextFieldDelegate {

    
    /// flag whether the user is on Email Log In screen or not
    var emailLoginScreen = false
    
    /// declare animation engine
    var animEngine: AnimationEngine!
    
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// assign text field delegates
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        /// initialise animation engine and pass in object constraints for handling
        self.animEngine = AnimationEngine(set1Constraints: [facebookBtnConstraint, googleBtnConstraint, emailBtnConstraint], set2Constraints: [emailFieldConstraint, passwordFieldConstraint, loginBtnConstraint, or2Constraint, createAccountBtnConstraint])
        
        /// set up swipe-right gesture for navigating back from the email log in screen to social media log in screen
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(LoginVC.backToSocialLogin(_:)))
        swipeRight.direction = .Right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    
    /// initial animation of log in objects onto screen
    override func viewDidAppear(animated: Bool) {
        self.animEngine.animateLogInObjects(1, set1Destination: "centre", set2Destination: "right")
    }
    
    
    /// handle swipe gesture to return to social media log in screen
    func backToSocialLogin(gesture: UIGestureRecognizer) {
        if emailLoginScreen == true {
            self.animEngine.animateLogInObjects(0, set1Destination: "centre", set2Destination: "right")
        }
    }
    
    
    /// press Log in with Email button and animate to second log in screen & set screen flag to Email Log in
    @IBAction func logInWithEmailPressed(sender: AnyObject) {
        self.animEngine.animateLogInObjects(0.2, set1Destination: "left", set2Destination: "centre")
        emailLoginScreen = true
    }

    
    /// dismiss keyboard when area outside keyboard pressed
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// dismiss keyboard when return key pressed
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 

        
}

