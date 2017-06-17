//
//  Album.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class Album {
    
    // declare Album object properties
    var albumID: String
    var ownerID: String
    var title: String
    var description: String
    var createdDate: Date
    var availableDate: Date
    var contributors: [Contributor]
    var coverURL: String?
    var coverImage: UIImage?
    var isActive: Bool
    
    // initialize Album object
    init (albumID: String, ownerID: String, title: String, description: String, createdDate: Date, availableDate: Date, contributors: [Contributor], coverURL: String?, coverImage: UIImage?, isActive: Bool) {
        self.albumID = albumID
        self.ownerID = ownerID
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.availableDate = availableDate
        self.contributors = contributors
        self.coverURL = coverURL
        self.coverImage = coverImage
        self.isActive = isActive
    }
    
    // return the count of media items the owner has so far added to the album
    func ownerMediaCount() -> Int {
        for user in contributors {
            if user.userID == ownerID {
                return user.photosTaken
            }
        }
        return 0
    }

    // return the number of media items that the album currently contains
    func albumMediaCount() -> Int {
        var mediaCount = 0
        for contributor in contributors {
            mediaCount += contributor.photosTaken
        }
        return mediaCount
    }


}
