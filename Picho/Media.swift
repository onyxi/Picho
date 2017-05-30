//
//  Media.swift
//  Picho
//
//  Created by Pete on 23/04/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class Media {

//    private var _ownerID: String
//    private var _ownerUsername: String
//    private var _url: String?
//    private var _image: UIImage?
//    private var _createdDate: Date
    
    var ownerID: String
    var ownerUsername: String
    var mediaURL: String?
    var image: UIImage?
    var mediaID: String
    var createdDate: Date
   
    init(ownerID: String, ownerUsername: String, mediaURL: String?, image: UIImage?, mediaID: String, createdDate: Date) {
        self.ownerUsername = ownerUsername
        self.ownerID = ownerID
        self.mediaURL = mediaURL
        self.image = image
        self.mediaID = mediaID
        self.createdDate = createdDate
    }
    
}
