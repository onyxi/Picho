//
//  DataService.swift
//  Picho
//
//  Created by Pete on 09/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


protocol FetchDataAfterLogInDelegate {
    func fetchDataAfterLogIn()
}





class DataService {
    private static let _instance = DataService()
    static var instance: DataService {
        return _instance
    }
    
    var fetchAlbumsDelegate: FetchAlbumsDelegate?
    
    /// Firebase Database
    
    var mainDBRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var mainStorageRef: FIRStorageReference {
        return FIRStorage.storage().reference(forURL: "gs://picho-51f78.appspot.com")
    }
    
    
    
    
    
    
    
    
    
    
    var albumCoversStorageRef: FIRStorageReference {
        return mainStorageRef.child("albumCovers")
    }
    
    var albumMediaStorageRef: FIRStorageReference {
        return mainStorageRef.child("albumMedia")
    }
    
    var profileMediaStorageRef: FIRStorageReference {
        return mainStorageRef.child("profileMedia")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // save an album to data
    func saveAlbumToFirebase(ownerID: String, album: Album, albumCover: UIImage) {
        
        // upload album cover and get download URL
        
        let albumCoverURL = uploadImageFromLocal(type: "albumCover", image: albumCover)
        
        // save album data
        let albumData: Dictionary<String, AnyObject> = [
            "availableDate": (album.availableDate.timeIntervalSince1970 * 1000).rounded() as AnyObject,
            "coverURL": albumCoverURL as AnyObject,
            //album.coverURL as AnyObject,
            "createdDate": FIRServerValue.timestamp() as AnyObject,
            "description": album.description as AnyObject,
            //"mediaCount": albualbumMediaCountnt as AnyObject,
            "title": album.title as AnyObject
        ]
        
        let uniqueAlbumRef = "\(NSUUID().uuidString)"
        let albumRef = mainDBRef.child(Constants.FIR_USERALBUMS).child("\(ownerID)").child(uniqueAlbumRef)
        albumRef.setValue(albumData)
        
        // extract contributors list
        var contributorsList: Dictionary<String, AnyObject> = [:]
        
        for index in 1...album.contributors.count {
            let contributorData: Dictionary<String, AnyObject> = [
                "username": album.contributors[index - 1].username as AnyObject,
                "photosRemaining": album.contributors[index - 1].photosRemaining as AnyObject,
                "photosTaken": album.contributors[index - 1].photosTaken as AnyObject
            ]
            
            let contributorID = album.contributors[index - 1].userID
            contributorsList["\(contributorID)"] = contributorData as AnyObject?
        }
        
        let contributorsRef = albumRef.child("contributors")
        contributorsRef.setValue(contributorsList)
        
        
    }
    
    
    
    
    /// Firebase Storage /// -----------------------------------------------------------------------------
    
    
    /// [upload image]
    func uploadImageFromLocal (type: String, image: UIImage) -> String? {
        
        // prepare image object
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else { return nil }
        
        // prepare metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        var imageRef: FIRStorageReference!
        let unique = NSUUID().uuidString
        
        switch (type) {
        case "albumCover":
            imageRef = self.albumCoversStorageRef.child("\(unique).jpg")
            break
        case "albumMedia":
            imageRef = self.albumMediaStorageRef.child("\(unique).jpg")
            break
        case "profileMedia":
            imageRef = self.profileMediaStorageRef.child("profilePicture.jpg")
            break
        default:
            break
        }
        
        var mediaDownloadURL: String?
        
        // Upload the object to the path
        _ = imageRef.put(imageData, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("error: \(error?.localizedDescription)")
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            let url = downloadURL()
            mediaDownloadURL = url?.absoluteString
            print(mediaDownloadURL)
            //    print (url)
            //    print (imageRef)
            
            /// save media details to database
            //  let uid = UserDefaults.standard.value(forKey: "loggedInUserID")!
            //  let mediaURL = url!.absoluteString as AnyObject
            //  self.mainRef.child("users").child("\(uid)").child("profile").child("profilePicURL").setValue(mediaURL)
        }
        
        return mediaDownloadURL
    }
    /// [end upload image]
    
    
    /// [download image]
    func downloadImageFromStorageURL (url: String) {
        var image: UIImage?
        
        let httpsReference = FIRStorage.storage().reference(forURL: url)
        httpsReference.data(withMaxSize: 1 * 1024 * 1024) { (data: Data?, error: Error?) in
            if let error = error {
                print (error.localizedDescription)
            } else {
                image = UIImage(data: data!)
                print (image)
            }
        }
        
        
    }
    
    /// [end download image]
    
    
    
    
    
    
    
    private func uploadMediaToFirebaseStorage (type: String, media: UIImage) {
        
        // prepare image object
        guard let mediaData = UIImagePNGRepresentation(media) else { return }
        
        // prepare metadata
        var mediaRef: FIRStorageReference!
        
        let unique = NSUUID().uuidString
        
        switch (type) {
        case "albumCover":
            mediaRef = self.albumCoversStorageRef.child("\(unique).jpg")
            break
        case "albumMedia":
            mediaRef = self.albumMediaStorageRef.child("\(unique).jpg")
            break
        case "profileMedia":
            mediaRef = self.profileMediaStorageRef.child("profilePicture.jpg")
            break
        default:
            break
        }
        
        mediaRef.put(mediaData, metadata: nil) { (metaData, error) in
            if error != nil {
                print (error)
                return
            }
            
            
            
            
            
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    /// -----------------------
    
    
    // save a user to data
    func createNewUser(uid: String, email: String? = "", password: String, username: String? = "") {
        
        let profile: Dictionary<String, AnyObject> = ["email": email as AnyObject, "password" : password as AnyObject, "username": username as AnyObject, "profilePicURL" : "placeholder" as AnyObject]
        
        mainDBRef.child("users").child(uid).child("profile").setValue(profile)
        
    }

    
    
    func getAndStoreLoggedInUserInfo(userID : String, loggingIn: Bool) {
        let userRef = mainDBRef.child("users").child(userID)
        userRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            if let userData = snapshot.value as? [String : AnyObject] {
                for user in userData {
                    let email = user.value["email"] as! String
                    let password = user.value["password"] as! String
                    let username = user.value["username"] as! String
                    let profilePicURL = user.value["profilePicURL"] as! String
                    
                    UserDefaults.standard.set(userID, forKey: "currentUserID")
                    UserDefaults.standard.set(email, forKey: "currentEmail")
                    UserDefaults.standard.set(username, forKey: "currentUsername")
                    UserDefaults.standard.set(password, forKey: "currentPassword")
                    UserDefaults.standard.set(profilePicURL, forKey: "currentProfilePicURL")
                    
//                    LoggedInUser.myUserID = userID
//                    LoggedInUser.myUsername = username
//                    LoggedInUser.myEmail = email
//                    LoggedInUser.myPassword = password
//                    LoggedInUser.myProfilePicURL = profilePicURL
//                    LoggedInUser.isLoaded = true
                    
                    print ( userID, username, email, password, profilePicURL )
                    
                    // UPLOAD DEVELOPMENT DATA
                    //DevData.instance.uploadDataToFirebase()
                    
                }
            }
        }
    }
    
    
    func signOutLocal() {
        UserDefaults.standard.set(nil, forKey: "myUserID")
        UserDefaults.standard.set(nil, forKey: "myEmail")
        UserDefaults.standard.set(nil, forKey: "myUsername")
        UserDefaults.standard.set(nil, forKey: "myPassword")
        UserDefaults.standard.set(nil, forKey: "myProfilePicURL")
        UserDefaults.standard.set(false, forKey: "isLoaded")
        
//        LoggedInUser.myUserID = nil
//        LoggedInUser.myUsername = nil
//        LoggedInUser.myEmail = nil
//        LoggedInUser.myPassword = nil
//        LoggedInUser.myProfilePicURL = nil
//        LoggedInUser.isLoaded = nil
    }
    
    
    func createNewUser() {
        // do something
    }
    
    func updateUserData() {
        // do something
    }
    
    
    
    
    func createNewAlbum(album: Album, albumCover: UIImage) {
        
        // prepare album cover object
        guard let coverData = UIImagePNGRepresentation(albumCover) else { return }
        
        let coverRef = self.albumCoversStorageRef.child("\(NSUUID().uuidString).jpg")
        
        coverRef.put(coverData, metadata: nil) { (metaData, error) in
            if error != nil {
                print (error?.localizedDescription)
                return
            }
            
            if let coverDownloadURL = metaData?.downloadURL()?.absoluteString {
                
                let albumData = [
                    "coverURL" : coverDownloadURL as AnyObject,
                    "title" : album.title as AnyObject,
                    "description" : album.description as AnyObject,
                    "createdDate" : FIRServerValue.timestamp() as AnyObject,
                    "availableDate" : (album.availableDate.timeIntervalSince1970 * 1000).rounded() as AnyObject,
                    //"mediaCount" : albualbumMediaCountnt as AnyObject
                ]
                
                let albumID = "\(NSUUID().uuidString)"
                let albumRef = self.mainDBRef.child(Constants.FIR_USERALBUMS).child("\(album.ownerID)").child(albumID)
                albumRef.updateChildValues(albumData, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print (error?.localizedDescription)
                    } else {
                        print ("new album added")
                    }
                })
                
                // extract contributors list
                var contributorsList: Dictionary<String, AnyObject> = [:]
                
                for contributor in album.contributors {
                    let contributorData: Dictionary<String, AnyObject> = [
                        "username": contributor.username as AnyObject,
                        "photosRemaining": contributor.photosRemaining as AnyObject,
                        "photosTaken": contributor.photosTaken as AnyObject
                    ]
                    
                    let contributorID = contributor.userID
                    contributorsList["\(contributorID)"] = contributorData as AnyObject?
                    
                }
                
                let contributorsRef = albumRef.child("contributors")
                contributorsRef.setValue(contributorsList)
                
            }
        }
    }
    
    func updateAlbumData() {
        // do something
    }
    
    
    func createNewMedia(owner: User, albumRef: String, media: UIImage) {
        
        // create media data
        // set up storage ref
        // upload data and retrieve download url
        
        // set up database ref
        // set up database object/Dictionary
        // save data to database
        
    }
    
    func updateMediaData() {
        // do something
    }
    
    
    //-----------------------------------------------------
    
    func fetchUser() {
        // do something
    }
    
//    // get album data from Firebase database
//    func fetchAlbumData(user: User) {
//        print ("Fetching albums")
//        var unpackedAlbums = [Album]()
//        let ownerID = user.userID
//        let albumsRef = mainDBRef.child("userAlbums").child(ownerID).observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
//          
//            if let albumsDict = snapshot.value as? [String: AnyObject] {
//                for album in albumsDict {
//                    let storedCreatedDate = album.value["createdDate"] as! Int
//                    let createdDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
//                    
//                    let storedAvailableDate = album.value["availableDate"] as! Int
//                    let availableDate = Date(timeIntervalSince1970: TimeInterval(storedAvailableDate))
//                    
//                    var unpackedContributorsList: [Contributor] = []
//                    if let contributorsDict = album.value["contributors"] as? [String: AnyObject] {
//                        for contributor in contributorsDict {
//                            let unpackedContributor = Contributor(
//                                userID: contributor.key as! String,
//                                username: contributor.value["username"] as! String,
//                                photosRemaining: contributor.value["photosRemaining"] as! Int,
//                                photosTaken: contributor.value["photosTaken"] as! Int
//                            )
//                            unpackedContributorsList.append(unpackedContributor)
//                        }
//                    }
//                    
//                    let unpackedAlbum = Album(
//                        owner: ownerID,
//                        title: album.value["title"] as! String,
//                        description: album.value["description"] as! String,
//                        createdDate: createdDate,
//                        availableDate: availableDate,
//                        contributors: unpackedContributorsList,
//                        coverURL: album.value["coverURL"] as! String,
//                        mediaCount: album.value["mediaCount"] as! Int,
//                        isActive: album.value["isActive"] as! Bool
//                    )
//                    unpackedAlbums.append(unpackedAlbum)
//                }
//                // return data
//                self.fetchAlbumsDelegate?.didFetchAlbumsData(data: unpackedAlbums)
//            }
//        }
//        
//    }
    
    
    func fetchAlbumMedia() {
        // do something
    }
    
    
    
    
}
