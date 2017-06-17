//
//  Media.swift
//  Picho
//
//  Created by Pete on 23/04/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class Media {
    
    // declare Media object properties
    var ownerID: String
    var ownerUsername: String
    var mediaID: String
    var mediaURL: String?
    var image: UIImage?
    var createdDate: Date
   
    // initialize Media object
    init(ownerID: String, ownerUsername: String, mediaID: String, mediaURL: String?, image: UIImage?, createdDate: Date) {
        self.ownerID = ownerID
        self.ownerUsername = ownerUsername
        self.mediaID = mediaID
        self.mediaURL = mediaURL
        self.image = image
        self.createdDate = createdDate
    }
    
}
