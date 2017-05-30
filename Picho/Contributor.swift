//
//  Contributor.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

struct Contributor {
    private var _userID: String
    private var _username: String
    private var _photosRemaining: Int
    private var _photosTaken: Int
    
    var userID : String { return _userID }
    var username: String { return _username }
    var photosRemaining: Int { return _photosRemaining }
    var photosTaken: Int { return _photosTaken }
    
    
    init (userID: String, username: String, photosRemaining: Int, photosTaken: Int) {
        _userID = userID
        _username = username
        _photosRemaining = photosRemaining
        _photosTaken = photosTaken
    }
    

    
}
