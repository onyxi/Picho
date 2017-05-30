//
//  Notif.swift
//  Picho
//
//  Created by Pete on 11/04/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class Notif {
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
    
//    var createdDate: Date { return _createdDate }
//    var notifType: String { return _notifType }
//    
//    var ownerUsername: String? { return _ownerUsername }
//    var objectType: String? { return _objectType }
//    var title: String? { return _title }
//    
//    
//    var objectOwnerID: String? { return _objectOwnerID }
//    var albumID: String? { return _albumID }
//    var mediaID: String? { return _mediaID }
//    
//    

    
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
          
          
          
//        createdDate: Date, notifType: String, ownerUsername: String?, objectType: String?, title: String?, objectOwnerID: String?, albumID: String?, mediaID: String?) {
//        _createdDate = createdDate
//        _notifType = notifType
//        _ownerUsername = ownerUsername
//        _objectType = objectType
//        _title = title
//        _objectOwnerID = objectOwnerID
//        _albumID = albumID
//        _mediaID = mediaID
   // }
    
}






