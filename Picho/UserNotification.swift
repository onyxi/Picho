//
//  UserNotification.swift
//  Picho
//
//  Created by Pete on 11/04/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class UserNotification {
    
    // declare UserNotification object properties
    var userID: String
    var createdDate: Date
    var notifType: String
    var objectType: String?
    var objectOwnerID: String?
    var objectOwnerUsername: String?
    var albumID: String?
    var mediaID: String?
    var title: String?
    var image: UIImage?

    // initialize UserNotification object
    init (userID: String, createdDate: Date, notifType: String, objectType: String?, objectOwnerID: String?, objectOwnerUsername: String?, albumID: String?, mediaID: String?, title: String?, image: UIImage?) {
        self.userID = userID
        self.createdDate = createdDate
        self.notifType = notifType
        self.objectType = objectType
        self.objectOwnerID = objectOwnerID
        self.objectOwnerUsername = objectOwnerUsername
        self.albumID = albumID
        self.mediaID = mediaID
        self.title = title
        self.image = image
    }
    
    
}






