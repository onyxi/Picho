//
//  Contributor.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class Contributor {
    
    // declare Contributor object properties
    var userID: String
    var username: String
    var photosRemaining: Int
    var photosTaken: Int
    
    // initialize Contributor object
    init (userID: String, username: String, photosRemaining: Int, photosTaken: Int) {
        self.userID = userID
        self.username = username
        self.photosRemaining = photosRemaining
        self.photosTaken = photosTaken
    }
    
}
