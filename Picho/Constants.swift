//
//  Constants.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import Foundation

struct Constants {
    
    // Keys for Standard User Defaults :
    let CURRENTUSER_ID = "currentUserID"
    let CURRENTUSER_USERNAME = "currentUsername"
    let CURRENTUSER_EMAIL = "currentEmail"
    let CURRENTUSER_PASSWORD = "currentPassword"
    let CURRENTUSER_PROFILEPICURL = "currentProfilePicURL"
    let CURRENTUSER_ISLOADED = "isLoaded"
    
// **
    
    // Keys for Firebase Database references :
    let FIRD_USERS = "users"
    let FIRD_USERS_EMAIL = "email"
    let FIRD_USERS_PASSWORD = "password"
    let FIRD_USERS_PROFILEPICURL = "profilePicURL"
    let FIRD_USERS_USERNAME = "username"
    
    let FIRD_USERALBUMS = "userAlbums"
    let FIRD_USERALBUMS_COVERURL = "coverURL"
    let FIRD_USERALBUMS_TITLE = "title"
    let FIRD_USERALBUMS_DESCRIPTION = "description"
    let FIRD_USERALBUMS_CREATEDDATE = "createdDate"
    let FIRD_USERALBUMS_AVAILABLEDATE = "availableDate"
    let FIRD_USERALBUMS_ISACTIVE = "isActive"
    let FIRD_USERALBUMS_CONTRIBUTORS = "contributors"
    
    let FIRD_ALBUMMEDIA = "albumMedia"
    let FIRD_ALBUMMEDIA_MEDIAID = "mediaID"
    let FIRD_ALBUMMEDIA_CREATEDDATE = "createdDate"
    let FIRD_ALBUMMEDIA_MEDIAURL = "mediaURL"
    let FIRD_ALBUMMEDIA_OWNERID = "ownerID"
    
    let FIRD_USERNOTIFICATIONS = "userNotifications"
    let FIRD_USERNOTIFICATIONS_ALBUMID = "albumID"
    let FIRD_USERNOTIFICATIONS_MEDIAID = "mediaID"
    let FIRD_USERNOTIFICATIONS_CREATEDDATE = "createdDate"
    let FIRD_USERNOTIFICATIONS_NOTIFTYPE = "notifType"
    let FIRD_USERNOTIFICATIONS_OBJECTOWNERID = "objectOwnerID"
    let FIRD_USERNOTIFICATIONS_OBJECTTYPE = "objectType"
    
    let FIRD_CONTRIBUTORS = "contributors"
    let FIRD_CONTRIBUTORS_USERNAME = "username"
    let FIRD_CONTRIBUTORS_PHOTOSREMAINING = "photosRemaining"
    let FIRD_CONTRIBUTORS_PHOTOSTAKEN = "photosTaken"
    
// **
    
    // Keys for Firebase Storage references :
    let FIRS_ALBUMCOVERS = "albumCovers"
    let FIRS_ALBUMMEDIA = "albumMedia"
    let FIRS_USERMEDIA = "userMedia"
    
// **
    
    // Keys for Core Data Entities :
    let CD_ACTIVEALBUM = "ActiveAlbum"
    let CD_ACTIVEALBUM_COVERIMAGE = "coverImage"
    let CD_ACTIVEALBUM_AVAILABLEDATE = "availableDate"
    let CD_ACTIVEALBUM_CREATEDDATE = "createdDate"
    let CD_ACTIVEALBUM_LASTSELECTED = "lastSelected"
    let CD_ACTIVEALBUM_FIRSTSYNCHCOMPLETE = "firstSynchComplete"
    let CD_ACTIVEALBUM_ISACTIVE = "isActive"
    let CD_ACTIVEALBUM_SYNCHEDTOFIREBASE = "synchedToFirebase"
    let CD_ACTIVEALBUM_ALBUMID = "albumID"
    let CD_ACTIVEALBUM_COVERURL = "coverURL"
    let CD_ACTIVEALBUM_DESCRIPTIONTEXT = "descriptionText"
    let CD_ACTIVEALBUM_OWNERID = "ownerID"
    let CD_ACTIVEALBUM_TITLETEXT = "titleText"
    
    let CD_CONTRIBUTOR = "Contributor"
    let CD_CONTRIBUTOR_ALBUMID = "albumID"
    let CD_CONTRIBUTOR_USERID = "userID"
    let CD_CONTRIBUTOR_USERNAME = "username"
    let CD_CONTRIBUTOR_MEDIAREMAINING = "mediaRemaining"
    let CD_CONTRIBUTOR_MEDIATAKEN = "mediaTaken"
    
    let CD_CURRENTUSER = "CurrentUser"
    let CD_CURRENTUSER_PROFILEIMAGE = "profileImage"
    let CD_CURRENTUSER_EMAIL = "email"
    let CD_CURRENTUSER_PASSWORD = "password"
    let CD_CURRENTUSER_USERID = "userID"
    let CD_CURRENTUSER_USERNAME = "username"
    
    let CD_FILTER = "Filter"
    let CD_FILTER_LASTSELECTED = "lastSelected"
    let CD_FILTER_NAME = "name"
    
    let CD_MEDIA = "Media"
    let CD_MEDIA_MEDIAITEM = "mediaItem"
    let CD_MEDIA_CREATEDDATE = "createdDate"
    let CD_MEDIA_ISCOVER = "isCover"
    let CD_MEDIA_ALBUMID = "albumID"
    let CD_MEDIA_MEDIAID = "mediaID"
    let CD_MEDIA_MEDIAURL = "mediaURL"
    
}





