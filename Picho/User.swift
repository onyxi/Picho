//
//  User.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class User {
    
    // declare User object properties
    var userID: String
    var username: String
    var email: String
    var profilePicURL: String
    
    // initialize User object
    init (userID: String, username: String, email: String, profilePicURL: String) {
        self.userID = userID
        self.username = username
        self.email = email
        self.profilePicURL = profilePicURL
    }
    
}
