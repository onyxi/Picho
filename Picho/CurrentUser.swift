//
//  CurrentUser.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class CurrentUser: User {
    
    // declare additional CurrentUser object properties
    var password: String
    var isLoaded: Bool
   
    // intialise CurrentUser object
    init() {
        self.password = UserDefaults.standard.value(forKey: "currentPassword") as! String
        self.isLoaded = true
        super.init(
            userID: UserDefaults.standard.value(forKey: "currentUserID") as! String,
            username: UserDefaults.standard.value(forKey: "currentUsername") as! String,
            email: UserDefaults.standard.value(forKey: "currentEmail") as! String,
            profilePicURL: UserDefaults.standard.value(forKey: "currentProfilePicURL") as! String
        )
    }

}
