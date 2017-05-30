//
//  Album.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

struct Album {
    
    private var _albumID: String
    private var _ownerID: String
    private var _availableDate: Date
    private var _contributors: [Contributor]
    private var _coverURL: String?
    private var _coverImage: UIImage?
//    private var _coverID: String
    private var _createdDate: Date
    private var _description: String
   // private var _mediaCount: Int
    private var _title: String
    private var _isActive: Bool
    
    var albumID: String { return _albumID }
    var ownerID: String { return _ownerID }
    var availableDate: Date { return _availableDate }
    var contributors: [Contributor] { return _contributors }
    var coverURL: String? { return _coverURL }
    var coverImage: UIImage? { return _coverImage }
//    var coverID: String { return _coverID }
    var createdDate: Date { return _createdDate }
    var description: String { return _description }
    //var mediaCount: Int { return _mediaCount }
    var title: String { return _title }
    var isActive: Bool { return _isActive }
    
    init(albumID: String, ownerID: String, title: String, description: String, createdDate: Date, availableDate: Date, contributors: [Contributor], coverURL: String?,  coverImage: UIImage?, isActive: Bool ) {
         //mediaCount: Int, 
       

        _albumID = albumID
        _ownerID = ownerID
        _availableDate = availableDate
        _contributors = contributors
        _coverURL = coverURL
        _coverImage = coverImage
   //     _coverID = coverID
        _createdDate = createdDate
        _description = description
        //_mediaCount = mediaCount
        _title = title
        _isActive = isActive

    }
    
    func ownerMediaCount() -> Int {
        for user in contributors {
            if user.userID == ownerID {
                return user.photosTaken
            }
        }
        return 0
    }

    func albumMediaCount() -> Int {
        var mediaCount = 0
        for contributor in contributors {
            mediaCount += contributor.photosTaken
        }
        return mediaCount
    }


}
