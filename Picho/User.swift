//
//  User.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

struct User {
    private var _userID: String
    private var _username: String
    private var _email: String
    private var _profilePicURL: String
    
    var userID: String { return _userID }
    var username: String { return _username }
    var email: String { return _email }
    var profilePicURL: String { return _profilePicURL }
    
    init (userID: String, username: String, email: String, profilePicURL: String) {
        _userID = userID
        _username = username
        _email = email
        _profilePicURL = profilePicURL
    }
    
}
