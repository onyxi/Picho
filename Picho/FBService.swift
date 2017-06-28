//
//  FBService.swift
//  Picho
//
//  Created by Pete on 25/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import CoreData
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

protocol AuthenticateDelegate {
    func didAuthenticate()
}

protocol FetchAlbumsDelegate {
    func didFetchAlbumsData(pastAlbums: [Album], futureAlbums: [Album])
}

protocol FetchNotifsDelegate {
    func didFetchNotifs(fetchedNotifs: [UserNotification])
}

protocol FetchAlbumMediaDelegate {
    func didFetchAlbumMedia(fetchedMedia: [Media])
}

protocol UploadAlbumDelegate {
    func didUploadAlbum()
}

protocol UploadMediaDelegate {
    func didUploadMedia()
}

protocol FetchSingleAlbumDelegate {
    func didFetchSingleAlbum(album: Album)
}

typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class FBService {
    //    private static let _instance = FBService()
    //    static var instance: FBService {
    //        return _instance
    //    }
    
    var authenticateDelegate: AuthenticateDelegate?
    var fetchAlbumsDelegate: FetchAlbumsDelegate?
    var fetchNotifsDelegate: FetchNotifsDelegate?
    var fetchAlbumMediaDelegate: FetchAlbumMediaDelegate?
    var uploadAlbumDelegate: UploadAlbumDelegate?
    var deleteAlbumDelegate: DeleteAlbumDelegate?
    var uploadMediaDelegate: UploadMediaDelegate?
    var fetchSingleAlbumDelegate: FetchSingleAlbumDelegate?
    
    var mainDBRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var mainStorageRef: FIRStorageReference {
        return FIRStorage.storage().reference(forURL: "gs://picho-51f78.appspot.com")
    }
    
    
    // ----------------------------------------------------------
    
    // [START Auth processes]
    
    func signUp( email: String, password: String, onComplete: Completion?) {
        
        // create FB account with credentials - return user ID
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                
                // could not create account - show error to user
                self.handleFirebaseAuthError(error: error! as NSError, onComplete: onComplete)
                
            } else {
                if user?.uid != nil {
                    
                    // create record of user in FB database
                    let profile: Dictionary<String, AnyObject> = ["email": email as AnyObject, "password" : password as AnyObject, "username": email as AnyObject, "profilePicURL" : "placeholder" as AnyObject]
                    self.mainDBRef.child("users").child((user?.uid)!).child("profile").setValue(profile)
                    
                    // log in to FB account with credentials
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                        if error != nil {
                            
                            // could not log in - show error to user
                            self.handleFirebaseAuthError(error: error as! NSError, onComplete: onComplete)
                            
                        }
                        
                        // store user's data on disk and in memory
                        UserDefaults.standard.set(user?.uid, forKey: "currentUserID")
                        UserDefaults.standard.set(email, forKey: "currentUsername")
                        UserDefaults.standard.set(email, forKey: "currentEmail")
                        UserDefaults.standard.set(password, forKey: "currentPassword")
                        UserDefaults.standard.set("placeholder", forKey: "currentProfilePicURL")
                        UserDefaults.standard.set(true, forKey: "isLoaded")
//                        LoggedInUser.myUserID = user?.uid
//                        LoggedInUser.myUsername = email
//                        LoggedInUser.myEmail = email
//                        LoggedInUser.myPassword = password
//                        LoggedInUser.myProfilePicURL = "placeholder"
//                        LoggedInUser.isLoaded = true
                        
                        // we have successfully logged in - return user data to caller
                        onComplete?(nil, user)
                        
                        // call back to fetch user data
                        self.authenticateDelegate?.didAuthenticate()
                        
                    })
                }
            }
        })
    }
    
    
    
    func signIn(email: String, password: String, onComplete: Completion?) {
        
        // log in with credentials
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                
                // could not log in - show error
                self.handleFirebaseAuthError(error: error! as NSError, onComplete: onComplete)
                
            } else {
                let userID = user?.uid
                
                // fetch user's data from Database
                let userRef = self.mainDBRef.child("users").child(userID!)
                userRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
                    
                    // unpack user's data
                    if let userData = snapshot.value as? [String : AnyObject] {
                        for user in userData {
                            let email = user.value["email"] as! String
                            let password = user.value["password"] as! String
                            let username = user.value["username"] as! String
                            let profilePicURL = user.value["profilePicURL"] as! String
                            
                            // store user's data in memory
                            UserDefaults.standard.set(userID, forKey: "myUserID")
                            UserDefaults.standard.set(username, forKey: "myUsername")
                            UserDefaults.standard.set(email, forKey: "myEmail")
                            UserDefaults.standard.set(password, forKey: "myPassword")
                            UserDefaults.standard.set(profilePicURL, forKey: "myProfilePicURL")
                            UserDefaults.standard.set(true, forKey: "isLoaded")
//                            LoggedInUser.myUserID = userID
//                            LoggedInUser.myUsername = username
//                            LoggedInUser.myEmail = email
//                            LoggedInUser.myPassword = password
//                            LoggedInUser.myProfilePicURL = profilePicURL
//                            LoggedInUser.isLoaded = true
                            
                            // call back to fetch user data
                            self.authenticateDelegate?.didAuthenticate()
                        }
                    }
                }
                
                // we have successfully logged in - return user data to caller
                onComplete?(nil, user)
            }
        })
    }
    
    
    // provide auth error feedback
    func handleFirebaseAuthError (error: NSError, onComplete: Completion?) {
        print (error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error._code) {
            switch (errorCode) {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("Invalid Password", nil)
                break
            case .errorCodeEmailAlreadyInUse:
                onComplete?("Email already in use", nil)
            case .errorCodeUserNotFound:
                onComplete?("Account not found", nil)
            default:
                onComplete?("There was a problem authenticating, please try again", nil)
                break
            }
            
        }
    }
    
    
    
    // save a new user to firebase
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
    
    
    
    func loadUserDataFromFB(userID: String) {
        
        // fetch user's data from Database
        let userRef = self.mainDBRef.child("users").child(userID)
        userRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            
            // unpack user's data
            if let userData = snapshot.value as? [String : AnyObject] {
                for user in userData {
                    let email = user.value["email"] as! String
                    let password = user.value["password"] as! String
                    let username = user.value["username"] as! String
                    let profilePicURL = user.value["profilePicURL"] as! String
                    
                    // store user's data on disk and in memory
                    UserDefaults.standard.set(userID, forKey: "myUserID")
                    UserDefaults.standard.set(email, forKey: "myEmail")
                    UserDefaults.standard.set(username, forKey: "myUsername")
                    UserDefaults.standard.set(password, forKey: "myPassword")
                    UserDefaults.standard.set(profilePicURL, forKey: "myProfilePicURL")
//                    LoggedInUser.myUserID = userID
//                    LoggedInUser.myUsername = username
//                    LoggedInUser.myEmail = email
//                    LoggedInUser.myPassword = password
//                    LoggedInUser.myProfilePicURL = profilePicURL
//                    LoggedInUser.isLoaded = true
                    
                    print ("User loaded")
                    
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
    
    
    // [END Auth processes]
    
    // ----------------------------------------------------------
    
    
    // [START fetch album data]
    
    
    func fetchLocalActiveAlbums() -> [Album]? {
        var localActiveAlbums = [Album]()
        // get active albums from core data
        
        return localActiveAlbums
    }
    
    
    func fetchSingleAlbumData(ownerID: String, albumID: String) {
        var albumToReturn: Album?
        let queryRef = mainDBRef.child("userAlbums").child(ownerID).child(albumID)
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let storedCreatedDate = snapshot.childSnapshot(forPath: "createdDate").value as! Int
            let createdDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
            let storedAvailableDate = snapshot.childSnapshot(forPath: "availableDate").value as! Int
            let availableDate = Date(timeIntervalSince1970: TimeInterval(storedAvailableDate))
            
            var unpackedContributorsList: [Contributor] = []
            if let contributorsDict = snapshot.childSnapshot(forPath: "contributors").value as? [String: AnyObject] {
                for contributor in contributorsDict {
                    let unpackedContributor = Contributor(
                        userID: contributor.key as! String,
                        username: contributor.value["username"] as! String,
                        photosRemaining: contributor.value["photosRemaining"] as! Int,
                        photosTaken: contributor.value["photosTaken"] as! Int
                    )
                    unpackedContributorsList.append(unpackedContributor)
                }
            }
            let unpackedAlbum = Album(
                albumID: albumID,
                ownerID: ownerID,
                title: snapshot.childSnapshot(forPath: "title").value as! String,
                description: snapshot.childSnapshot(forPath: "description").value as! String,
                createdDate: createdDate,
                availableDate: availableDate,
                contributors: unpackedContributorsList,
                coverURL: snapshot.childSnapshot(forPath: "coverURL").value as! String,
                coverImage: nil,
                //mediaCount: snapshot.childSnapshot(forPath: "mediaCount").value as! Int,
                isActive: snapshot.childSnapshot(forPath: "isActive").value as! Bool
            )
            
            albumToReturn = unpackedAlbum
            print (albumToReturn)
            self.fetchSingleAlbumDelegate?.didFetchSingleAlbum(album: albumToReturn!)

        })
        
    }
    
    
    
    func fetchAlbumData(user: User) {
        print ("Fetching albums")
        var unpackedPastAlbums = [Album]()
        var unpackedFutureAlbums = [Album]()
        
        // get local active albums
//        if let activeAlbums = CoreDataModel.fetchActiveAlbums() {
//            unpackedFutureAlbums = activeAlbums
//        }
        
        
        // get cloud inactive albums
        let ownerID = user.userID
        //let albumsRef = mainDBRef.child("userAlbums").child(ownerID)
        let queryRef = mainDBRef.child("userAlbums").child(ownerID).queryOrdered(byChild: "title")
        //albumsRef.queryOrdered(byChild: "title").observe(FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
        //observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
        //queryRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // if let albumsDict = snapshot.value as? [String: AnyObject] {
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    let storedCreatedDate = snap.childSnapshot(forPath: "createdDate").value as! Int
                    //value["createdDate"] as! Int
                    let createdDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
               //     print (snap)
                    let storedAvailableDate = snap.childSnapshot(forPath: "availableDate").value as! Int
                    //value["availableDate"] as! Int
                    let availableDate = Date(timeIntervalSince1970: TimeInterval(storedAvailableDate))
                    
                    var unpackedContributorsList: [Contributor] = []
                    
                    //let contributorsSnapshot = snap.childSnapshot(forPath: "contributors").value
                    //if let contributorSnapshots = contributorsSnapshot.children.allObjects as? [FIRDataSnapshot] {
                    
                    //}
                    //snap.children.allObjects as?
                    //childSnapshot(forPath: "contributors").value as? [String: AnyObject] {
                    //value["contributors"] as? [String: AnyObject] {
                    if let contributorsDict = snap.childSnapshot(forPath: "contributors").value as? [String: AnyObject] {
                        for contributor in contributorsDict {
                            let unpackedContributor = Contributor(
                                userID: contributor.key as! String,
                                username: contributor.value["username"] as! String,
                                photosRemaining: contributor.value["photosRemaining"] as! Int,
                                photosTaken: contributor.value["photosTaken"] as! Int
                            )
                            unpackedContributorsList.append(unpackedContributor)
                        }
                    }
                    
                    let unpackedAlbum = Album(
                        albumID: snap.key as! String,
                        ownerID: ownerID,
                        title: snap.childSnapshot(forPath: "title").value as! String,
                        //album.value["title"] as! String,
                        description: snap.childSnapshot(forPath: "description").value as! String,
                        //album.value["description"] as! String,
                        createdDate: createdDate,
                        availableDate: availableDate,
                        contributors: unpackedContributorsList,
                        coverURL: snap.childSnapshot(forPath: "coverURL").value as! String,
                        coverImage: nil,
                 //       coverID: snap.childSnapshot(forPath: "coverID").value as! String,
                        //album.value["coverURL"] as! String,
                        //mediaCount: snap.childSnapshot(forPath: "mediaCount").value as! Int,
                        //album.value["mediaCount"] as! Int,
                        isActive: snap.childSnapshot(forPath: "isActive").value as! Bool
                        //album.value["isActive"] as! Bool
                    )
                    if unpackedAlbum.isActive == false {
                        unpackedPastAlbums.append(unpackedAlbum)
                    } else {
                        // synch local Album data with this server instance          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        //unpackedFutureAlbums.append(unpackedAlbum)
                    }
                    
                }
                // return data
                self.fetchAlbumsDelegate?.didFetchAlbumsData(pastAlbums: unpackedPastAlbums, futureAlbums: unpackedFutureAlbums)
                //}
            }
        })
    }
    // [END fetch album data]
    
    
    
    // [START fetch current album]
    
//    func fetchCurrentAlbum() -> Album? {
//        
//        // get current album from core data
//        
//        guard let currentAlbumID = UserDefaults.standard.value(forKey: "currentlySelectedAlbumID") else { return nil }
//        
//        
//        
//        guard let userID = LoggedInUser.myUserID else { return nil }
//        
////        let albumRef = mainDBRef.child(userID).child(albumID)
////        
////        albumRef.observeSingleEvent(of: .value, with: { (snap) in
////            print (snap)
////        })
////        
////        return nil
//        
//    }
    
    // [END fetch current album]
    
    
    
    
    // [START fetch media data]
    
    func fetchAlbumMedia(album: Album) {
        var fetchedMedia = [Media]()
    
        let currentUser = CurrentUser()
        
        if album.isActive == true {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate?.managedObjectContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Media")
            var results: [NSManagedObject] = []
            
            let predicate = NSPredicate(format: "%K == %@", "albumID", album.albumID)
            fetchRequest.predicate = predicate
            
            let sectionSortDescriptor = [NSSortDescriptor(key: "createdDate", ascending: true)]
            fetchRequest.sortDescriptors = sectionSortDescriptor
            
            do {
                if let fetchResult = try? managedContext?.fetch(fetchRequest) {
                    results = fetchResult!
                }
            }
            
            for result in results {
                let media = Media(ownerID: currentUser.userID, ownerUsername: currentUser.username, mediaID: result.value(forKey: "mediaID") as! String, mediaURL: nil, image: result.value(forKey: "mediaItem") as! UIImage, createdDate: result.value(forKey: "createdDate") as! Date)
                fetchedMedia.append(media)
            }
            
            self.fetchAlbumMediaDelegate?.didFetchAlbumMedia(fetchedMedia: fetchedMedia)
        } else {
            
            var mediaCount = 0
            for contributor in album.contributors {
                mediaCount += contributor.photosTaken
            }
            
            let albumMediaRef = self.mainDBRef.child("albumMedia").child(album.albumID)
            albumMediaRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let allAlbumMedia = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for mediaItem in allAlbumMedia {
                        
                        var mediaID: String { return mediaItem.key }
                        let storedCreatedDate = mediaItem.childSnapshot(forPath: "createdDate").value as! Int
                        let mediaCreatedDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                        
                        let mediaURL = mediaItem.childSnapshot(forPath: "mediaURL").value as? String
                        let ownerID = mediaItem.childSnapshot(forPath: "ownerID").value as? String
                        
                        let userRef = self.mainDBRef.child("users").child(ownerID!).child("profile")
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            let mediaOwnerUsername = snapshot.childSnapshot(forPath: "username").value as! String
                            
                            let fetchedMediaItem = Media(ownerID: ownerID!, ownerUsername: mediaOwnerUsername, mediaID: mediaID, mediaURL: mediaURL!, image: nil, createdDate: mediaCreatedDate)
                            fetchedMedia.append(fetchedMediaItem)
                            
                            if fetchedMedia.count == mediaCount {
                                self.fetchAlbumMediaDelegate?.didFetchAlbumMedia(fetchedMedia: fetchedMedia)
                            }
                            
                        })
                    }
                }
            })
        }
    }
    
    
    
    // [END fetch media data]
    
    
    
    // [START fetch notification data]
    func fetchNotifs() {
        var notifMax = 15
        var fetchedNotifs = [UserNotification]()
        
        //guard let notifOwnerID = LoggedInUser.myUserID else { print ("could not fetch notifs"); return }
        let currentUser = CurrentUser()
        
        let notifsRef = mainDBRef.child("userNotifications").child(currentUser.userID)
        
        
        //////////// UNPACK PROPERLY AND FETCH OBJECT INFO FOR NOTIF ARRAY!!!
        
        //  (createdDate: Date, notifType: String, ownerUsername: String?, objectType: String?, title: String?, objectOwnerID: String?, albumID: String?, mediaID: String?) {
        
        
        notifsRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
        
            // update notifMax with number of items returned in the snapshot
            notifMax = Int(snapshot.childrenCount)
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    
                    // get type of notification object
                    let notifObjectType = snap.childSnapshot(forPath: "objectType").value as! String
                    
                    // get firebase ID of album and media (optional)
                    let notifAlbumID = snap.childSnapshot(forPath: "albumID").value as? String
                    let notifMediaID = snap.childSnapshot(forPath: "mediaID").value as? String
                    
                    // get type of notification
                    let notifType = snap.childSnapshot(forPath: "notifType").value as! String
                    
                    // get firebase ID of object's owner
                    let notifObjectOwnerID = snap.childSnapshot(forPath: "objectOwnerID").value as! String
                    
                    // get timestamp of notification
                    let storedCreatedDate = snap.childSnapshot(forPath: "createdDate").value as! Int
                    let notifCreatedDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                    
                    
                    // initialise variables to be fetched
                    var notifObjectOwnerUsername: String?
                    var notifObjectTitle: String?
                    var notifObjectMediaURL: String?
                    var notifImage: UIImage = UIImage(named: "food1")!
                    
                    
                    
                    // fetch object's associated info //
                    // fetch object owner's username
                    let objectOwnerRef = self.mainDBRef.child("users").child(notifObjectOwnerID).child("profile")
                    objectOwnerRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let username = snapshot.childSnapshot(forPath: "username").value as? String else {
                            print ("could not fetch owner's username")
                            return
                        }
                        notifObjectOwnerUsername = username
                        
                        // fetch object metadata
                        switch notifObjectType {
                        case "album" :
                            let objectRef = self.mainDBRef.child("userAlbums").child(notifObjectOwnerID).child(notifAlbumID!)
                            objectRef.observe(.value, with: { (snapshot) in
                       
                                guard let coverImageURL = snapshot.childSnapshot(forPath: "coverURL").value as? String else { return }
                                guard let albumTitle = snapshot.childSnapshot(forPath: "title").value as? String else { return }
                                notifObjectMediaURL = coverImageURL
                                notifObjectTitle = albumTitle
                             
                                // fetch object image
                                let url = NSURL(string: coverImageURL)
                                var request = URLRequest(url: url as! URL)
                                
                                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                    //download hit an error so let's return out
                                    if error != nil {
                                        print (error)
                                        return
                                    }
                                    
                                    DispatchQueue.main.async(execute: {
                                        if let downloadedImage = UIImage(data: data!) {
                                            notifImage = downloadedImage
                                            
                                            // all notif info fetched - can now create Notif
                                            let unpackedNotif = UserNotification(
                                                userID: currentUser.userID,
                                                createdDate: notifCreatedDate,
                                                notifType: notifType,
                                                objectType: notifObjectType,
                                                objectOwnerID: notifObjectOwnerID,
                                                objectOwnerUsername: notifObjectOwnerUsername,
                                                albumID: notifAlbumID,
                                                mediaID: notifMediaID,
                                                title: notifObjectTitle,
                                                image: notifImage
                                            )
                                            fetchedNotifs.append(unpackedNotif)
                                            if fetchedNotifs.count == notifMax {
                                                self.fetchNotifsDelegate?.didFetchNotifs(fetchedNotifs: fetchedNotifs)
                                            }
                                        }
                                    })
                                }
                                task.resume()
                                
                            })
                            return
                        case "media" :
                            let objectRef = self.mainDBRef.child("albumMedia").child(notifAlbumID!).child(notifMediaID!)
                            objectRef.observe(.value, with: { (snapshot) in
                                if let mediaImageURL = snapshot.childSnapshot(forPath: "mediaURL").value as? String {
                                    notifObjectMediaURL = mediaImageURL
                                    
                                    // fetch object image
                                    let url = NSURL(string: mediaImageURL)
                                    var request = URLRequest(url: url as! URL)
                                    
                                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                        //download hit an error so let's return out
                                        if error != nil {
                                            print (error)
                                            return
                                        }
                                        
                                        DispatchQueue.main.async(execute: {
                                            if let downloadedImage = UIImage(data: data!) {
                                                notifImage = downloadedImage
                                                
                                                // all notif info fetched - can now create Notif
                                                let unpackedNotif = UserNotification(
                                                    userID: currentUser.userID,
                                                    createdDate: notifCreatedDate,
                                                    notifType: notifType,
                                                    objectType: notifType,
                                                    objectOwnerID: notifObjectOwnerID,
                                                    objectOwnerUsername: notifObjectOwnerUsername,
                                                    albumID: notifAlbumID,
                                                    mediaID: notifMediaID,
                                                    title: notifObjectTitle,
                                                    image: notifImage
                                                )
                                                fetchedNotifs.append(unpackedNotif)
                                                if fetchedNotifs.count == notifMax {
                                                    self.fetchNotifsDelegate?.didFetchNotifs(fetchedNotifs: fetchedNotifs)
                                                }
                                            }
                                        })
                                    }
                                    task.resume()
                                    
                                }
                            })
                            return
                        default: break
                        }
                        
                        
                        // fetch object metadata
                        var notifObjectRef : FIRDatabaseReference? {
                            switch notifObjectType {
                            case "album" :
                                return self.mainDBRef.child("userAlbums").child(notifObjectOwnerID).child(notifAlbumID!)
                            case "media" :
                                return self.mainDBRef.child("albumMedia").child(notifAlbumID!).child(notifMediaID!)
                            default :
                                return self.mainDBRef.child("noRef")
                                break
                            }
                        }
                        notifObjectRef!.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            var imageRefKey: String {
                                switch notifObjectType {
                                case "album" :
                                    return "coverURL"
                                case "media" :
                                    return "mediaURL"
                                default :
                                    return "no image ref key"
                                    break
                                }
                            }
                            if let imageURL = snapshot.childSnapshot(forPath: imageRefKey).value as? String {
                                print (imageURL)
                                notifObjectMediaURL = imageURL
                            }
                        })
                    })
                    
                }
                
            }
        }
    }
    
    
    // [END fetch notification data]
    
    
    // [START upload album to firebase]
    
    func createNewAlbum(album: Album) {
        //title: String, description: String, availableDate: Date, coverImage: UIImage, contributors: [Contributor]) {
        
        let currentUser = CurrentUser()
        
        //guard let ownerID = currentUser.userID else { print ("user not logged in"); return }
        let ownerID = currentUser.userID
        
        let albumID = "\(NSUUID().uuidString)"
        
        
        if album.isActive {
            
            guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "ActiveAlbum", in: managedContext)
            let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
            objectToSave.setValue(album.albumID, forKey: "albumID")
            objectToSave.setValue(album.ownerID, forKey: "ownerID")
            objectToSave.setValue(album.coverImage, forKey: "coverImage")
            objectToSave.setValue(album.title, forKey: "titleText")
            objectToSave.setValue(album.description, forKey: "descriptionText")
            objectToSave.setValue(album.createdDate, forKey: "createdDate")
            objectToSave.setValue(album.availableDate, forKey: "availableDate")
            objectToSave.setValue(Date(), forKey: "lastSelected")
            objectToSave.setValue(true, forKey: "isActive")
            objectToSave.setValue(true, forKey: "synchedToFirebase")
            objectToSave.setValue(true, forKey: "firstSynchComplete")
            
            for contributor in album.contributors {
                let managedContext = appDelegate.managedObjectContext
                let entity = NSEntityDescription.entity(forEntityName: "Contributor", in: managedContext)
                let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
                objectToSave.setValue(album.albumID, forKey: "albumID")
                objectToSave.setValue(contributor.userID, forKey: "userID")
                objectToSave.setValue(contributor.username, forKey: "username")
                objectToSave.setValue(contributor.photosRemaining, forKey: "mediaRemaining")
                objectToSave.setValue(contributor.photosTaken, forKey: "mediaTaken")
                
                do { try managedContext.save() } catch {}
                
            }
            
            do { try managedContext.save() } catch {}
        }
        
        
        //let cover = coverImage
        guard let cover = album.coverImage else { return }
        guard let coverData = UIImagePNGRepresentation(cover) else { return }
        
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
        
        

        let coverRef = self.mainStorageRef.child("albumCovers").child(ownerID).child(albumID)
        coverRef.put(coverData, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
            if error != nil {
                print (error?.localizedDescription)
                return
            }
            if let coverDownloadURL = metadata?.downloadURL()?.absoluteString {
                
                let albumData = [
                    "coverURL" : coverDownloadURL as AnyObject,
                    "title" : album.title as AnyObject,
                    "description" : album.description as AnyObject,
                    "createdDate" : FIRServerValue.timestamp() as AnyObject,
                    "availableDate" : (album.availableDate.timeIntervalSince1970 * 1000).rounded() as AnyObject,
                    //"mediaCount" : 0 as AnyObject,
                    "isActive" : album.isActive as AnyObject,
                    "contributors" : contributorsList as AnyObject
                ]
                
                
                //guard let ownerID = LoggedInUser.myUserID else { return }
                let albumRef = self.mainDBRef.child(Constants.FIR_USERALBUMS).child(ownerID).child(albumID)
                albumRef.updateChildValues(albumData, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print (error?.localizedDescription)
                    } else {
                        self.uploadAlbumDelegate?.didUploadAlbum()
                    }
                })
                
//                // extract contributors list
//                var contributorsList: Dictionary<String, AnyObject> = [:]
//                
//                for contributor in contributors {
//                    let contributorData: Dictionary<String, AnyObject> = [
//                        "username": contributor.username as AnyObject,
//                        "photosRemaining": contributor.photosRemaining as AnyObject,
//                        "photosTaken": contributor.photosTaken as AnyObject
//                    ]
//                    
//                    let contributorID = contributor.userID
//                    contributorsList["\(contributorID)"] = contributorData as AnyObject?
//                    
//                }
//                
//                let contributorsRef = albumRef.child("contributors")
//                contributorsRef.updateChildValues(contributorsList, withCompletionBlock: { (error: Error?, ref) in
//                    if error != nil {
//                        print (error?.localizedDescription)
//                    } else {
//                        print ("contributors uploaded")
//                    }
//                })
                
            }
            
            
            
        })
        
        
    }
    
    // [END upload album to firebase]
    
    // [START commit media to album]
    
    func commitMediaToAlbum(media: UIImage, album: Album) {
        
        // get user from Core Data
        let userID = CurrentUser().userID // is this needed????
        
        // save media to Core Data
        
        // attempt to upload to firebase
        uploadMediaToFirebase(media: media, album: album)
    }
    
    // [END commit media to album]
    
    
    
    // [START upload media to Firebase]
    
    func uploadMediaToFirebase(media: UIImage, album: Album) {
        
        // get user from Core Data
        //let userID = LoggedInUser.myUserID
        let currentUser = CurrentUser()
        
        let mediaID = "\(NSUUID().uuidString)"
        
        let mediaStorageRef = self.mainStorageRef.child("albumMedia").child(album.albumID).child(mediaID)
        
        guard let mediaData = UIImagePNGRepresentation(media) else { return }
        
        mediaStorageRef.put(mediaData, metadata: nil) { (metadata, error) in
            if let error = error {
                print (error.localizedDescription)
            } else {
                
                guard let mediaURL = metadata?.downloadURL()?.absoluteString else { return }
                
                let mediaData = [
                    "createdDate" : FIRServerValue.timestamp() as AnyObject,
                    "mediaID" : mediaID as AnyObject,
                    "mediaURL" : mediaURL as AnyObject,
                    "ownerID" : currentUser.userID as AnyObject
                ]
                
                let mediaDatabaseRef = self.mainDBRef.child("albumMedia").child(album.albumID).child(mediaID)
                mediaDatabaseRef.updateChildValues(mediaData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        print (error.localizedDescription)
                    } else {
                        print ("media uploaded successfully")
                        
                    // callback now media upload complete
                    self.uploadMediaDelegate?.didUploadMedia()
                    }
                })
                
            }
        }
        
    }
    
    // [END upload media to Firebase]
    
    
    
    // [START delete media]
    func deleteMedia(mediaURL: String) {
        let mediaStorageRef = mainStorageRef.child("albumMedia").child(mediaURL)
        // delete image
    }
    // [END delete image]
    
    
    // [START delete album]
    func deleteAlbum(album: Album) {
        
        let albumRef = mainDBRef.child("userAlbums").child(album.ownerID).child(album.albumID)
        albumRef.removeValue { (error, ref) in
            if let error = error {
                print ("could not delete album data:\(error.localizedDescription)")
            } else {
                print ("album data deleted")
            }
        }
        let albumCoverRef = self.mainStorageRef.child("albumCovers").child(album.ownerID).child(album.albumID)
        albumCoverRef.delete { (error) in
            if let error = error {
                print ("could not delete album cover: \(error.localizedDescription)")
            } else {
                print ("album cover deleted")
            }
        }
        let albumMediaDataRef = self.mainDBRef.child("albumMedia").child(album.albumID)
        albumMediaDataRef.removeValue { (error, ref) in
            if let error = error {
                print ("could not delete album media data: \(error.localizedDescription)")
            } else {
                print ("album media data deleted")
            }
        }
        let albumMediaRef = self.mainStorageRef.child("albumMedia").child(album.ownerID).child(album.albumID)
        albumMediaRef.delete { (error) in
            if let error = error {
                print ("could not delete album media: \(error.localizedDescription)")
            } else {
                print ("album media deleted")
            }
        }
        
        // call back to unwind and refresh collection views
        self.deleteAlbumDelegate?.didDeleteAlbum()
        
    }
    // [END delete album]
    
    
    
    
    
    //--------------------------------------------
    // Fetch Filters
    static func fetchFilters () -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Filter")
        
        var results: [NSManagedObject] = []
        
        let sectionSortDescriptor = [NSSortDescriptor(key: "lastSelected", ascending: false)]
        fetchRequest.sortDescriptors = sectionSortDescriptor
        
        do {
            if let fetchResult = try? managedContext?.fetch(fetchRequest) {
                results = fetchResult!
            }
        }
        
        return results
    }
    
    // update filter usage data
    static func updateFilterInfo (filter: NSManagedObject) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        filter.setValue(Date(), forKey: "lastSelected")
        appDelegate.saveContext()
    }
    
    
    
    
}
