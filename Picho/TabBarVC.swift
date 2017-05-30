//
//  TabBarVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 01/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import FirebaseAuth


class TabBarVC: UITabBarController {
//   -------IB Outlets---------------------------
    
//   -------Declare Variables--------------------

//   -------Main View Events---------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }

    
    override func viewDidAppear(_ animated: Bool) {
    //    checkUserAuth()
    }
    
    
    
//   -------Methods---------------------------
    
//    func checkUserAuth () {
//        // check if Firebase user currently authenticated
//        guard FIRAuth.auth()?.currentUser != nil else {
//            performSegue(withIdentifier: "LoginVC", sender: nil)
//            return
//        }
//    }
    
    
//   -------General---------------------------
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    

}
