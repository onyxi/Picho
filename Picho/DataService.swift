//
//  DataService.swift
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

protocol AuthenticateDelegate { func didAuthenticate() }
protocol FetchAlbumsDelegate { func didFetchAlbumsData(pastAlbums: [Album], futureAlbums: [Album]) }
protocol FetchNotifsDelegate { func didFetchNotifs(fetchedNotifs: [UserNotification]) }
protocol FetchAlbumMediaDelegate { func didFetchAlbumMedia(fetchedMedia: [Media]) }
protocol UploadAlbumDelegate { func didUploadAlbum() }
protocol UploadMediaDelegate { func didUploadMedia() }
protocol FetchSingleAlbumDelegate { func didFetchSingleAlbum(album: Album) }

typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class DataService {
    
    // declare protocol delegate variables
    var authenticateDelegate: AuthenticateDelegate?
    var fetchAlbumsDelegate: FetchAlbumsDelegate?
    var fetchNotifsDelegate: FetchNotifsDelegate?
    var fetchAlbumMediaDelegate: FetchAlbumMediaDelegate?
    var uploadAlbumDelegate: UploadAlbumDelegate?
    var deleteAlbumDelegate: DeleteAlbumDelegate?
    var uploadMediaDelegate: UploadMediaDelegate?
    var fetchSingleAlbumDelegate: FetchSingleAlbumDelegate?
    
    // get Firebase database and storage root directories
    var mainDBRef = FIRDatabase.database().reference()
    var mainStorageRef = FIRStorage.storage().reference(forURL: "gs://picho-51f78.appspot.com")
    
    
    // -----------------USER AUTHORIZATION FUNCTIONS-----------------------------------------
    
    // [START sign-up to new account]
    
    // create a new user account in firebase
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
                    self.mainDBRef.child(Constants.FIR_USERS).child((user?.uid)!).child(Constants.FIR_PROFILE).setValue(profile)
                    
                    // log in to FB account with credentials
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                        if error != nil {
                            
                            // could not log in - show error to user
                            self.handleFirebaseAuthError(error: error! as NSError, onComplete: onComplete)
        
                        }
                        
                        // store user's data on disk and in memory
                        UserDefaults.standard.set(user?.uid, forKey: Constants.USER_ID)
                        UserDefaults.standard.set(email, forKey: Constants.USER_USERNAME)
                        UserDefaults.standard.set(email, forKey: Constants.USER_EMAIL)
                        UserDefaults.standard.set(password, forKey: Constants.USER_PASSWORD)
                        UserDefaults.standard.set("placeholder", forKey: Constants.USER_PROFILEPICURL)
                        UserDefaults.standard.set(true, forKey: Constants.USER_ISLOADED)

                        
                        // we have successfully logged in - return user data to caller
                        onComplete?(nil, user)
                        
                        // call back to fetch user data
                        self.authenticateDelegate?.didAuthenticate()
                        
                    })
                }
            }
        })
    }
    // [END sign-up to new account]
    
    
    //-----
    
    
    // [START sign-in to existing account]
    func signIn(email: String, password: String, onComplete: Completion?) {
        
        // log in with credentials
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                
                // could not log in - show error
                self.handleFirebaseAuthError(error: error! as NSError, onComplete: onComplete)
                
            } else {
                let userID = user?.uid
                
                // fetch user's data from Database
                let userRef = self.mainDBRef.child(Constants.FIR_USERS).child(userID!)
                userRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
                    
                    // unpack user's data
                    if let userData = snapshot.value as? [String : AnyObject] {
                        for user in userData {
                            let email = user.value["email"] as! String
                            let password = user.value["password"] as! String
                            let username = user.value["username"] as! String
                            let profilePicURL = user.value["profilePicURL"] as! String
                            
                            // store user's data in memory
                            UserDefaults.standard.set(userID, forKey: Constants.USER_ID)
                            UserDefaults.standard.set(username, forKey: Constants.USER_USERNAME)
                            UserDefaults.standard.set(email, forKey: Constants.USER_EMAIL)
                            UserDefaults.standard.set(password, forKey: Constants.USER_PASSWORD)
                            UserDefaults.standard.set(profilePicURL, forKey: Constants.USER_PROFILEPICURL)
                            UserDefaults.standard.set(true, forKey: Constants.USER_ISLOADED)
                            
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
    // [END sign-in to existing account]
    
    
    //-----
    
    
    // [START authorization error feedback after sign-up/in attempt]
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
    // [END authorization error feedback after sign-up/in attempt]
    
    
    //-----
    
    
    // [START sign out user from firebase]
    func signOutLocal() {
            
            UserDefaults.standard.set(nil, forKey: Constants.USER_ID)
            UserDefaults.standard.set(nil, forKey: Constants.USER_EMAIL)
            UserDefaults.standard.set(nil, forKey: Constants.USER_USERNAME)
            UserDefaults.standard.set(nil, forKey: Constants.USER_PASSWORD)
            UserDefaults.standard.set(nil, forKey: Constants.USER_PROFILEPICURL)
            UserDefaults.standard.set(false, forKey: Constants.USER_ISLOADED)

    }
    // [START sign out user from firebase]
    
    

    
    // -------------MANAGE ALBUM FUNCTIONS---------------------------------------------
    
    // [START create new album]
    // create a new album - save to local disk and attempt to save copy to firebase
    func createNewAlbum(album: Album) {
        
        let albumID = "\(NSUUID().uuidString)" // create random ID for new album
        
        if album.isActive { // save album to local disk
            
            // unpack Album object and save to CoreData
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
            
            // unpack Contributor objects and save to CoreData
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
        
        // upload album cover image to Firebase storage and return 'download url'
        guard let cover = album.coverImage else { return }
        guard let coverData = UIImagePNGRepresentation(cover) else { return }
        let coverRef = self.mainStorageRef.child("albumCovers").child(album.ownerID).child(albumID)
        coverRef.put(coverData, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
            if error != nil { // upload error occurred - provide feedback
                print (error?.localizedDescription)
                return
            }
            if let coverDownloadURL = metadata?.downloadURL()?.absoluteString {
                
                // package 'contributors' data as JSON object for Firebase
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
                
                // package 'album' data as JSON object for Firebase
                let albumData = [
                    "coverURL" : coverDownloadURL as AnyObject,
                    "title" : album.title as AnyObject,
                    "description" : album.description as AnyObject,
                    "createdDate" : FIRServerValue.timestamp() as AnyObject,
                    "availableDate" : (album.availableDate.timeIntervalSince1970 * 1000).rounded() as AnyObject,
                    "isActive" : album.isActive as AnyObject,
                    "contributors" : contributorsList as AnyObject
                ]
                
                // upload album data to Firebase database
                let albumRef = self.mainDBRef.child(Constants.FIR_USERALBUMS).child(album.ownerID).child(albumID)
                albumRef.updateChildValues(albumData, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print (error?.localizedDescription)
                    } else { // callback once album upload complete
                        self.uploadAlbumDelegate?.didUploadAlbum()
                    }
                })
            }
        })
    }
    // [END create new album]
    
    
    //-----
    
    
    // [START get active album(s) from core data]
    func fetchLocalActiveAlbums(albumID: String?) -> [Album]? {
        print ("Fetching active albums from disk")
        var localActiveAlbums = [Album]()
        
        // implement retrieval of active albums from local disk
        
        return localActiveAlbums
    }
    // [END get active album(s) from core data]
    
    
    //-----
    

    // [START get user albums from firebase]
    func fetchFirebaseAlbums(user: User) {
        print ("Fetching albums from Firebase")
        var unpackedInactiveAlbums = [Album]()
        var unpackedActiveAlbums = [Album]()
        
        // retrieve album data from Firebase
        let queryRef = mainDBRef.child(Constants.FIR_USERALBUMS).child(user.userID).queryOrdered(byChild: "title")
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // unpack album JSON data from Firebase
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    let storedCreatedDate = snap.childSnapshot(forPath: "createdDate").value as! Int
                    let createdDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                    let storedAvailableDate = snap.childSnapshot(forPath: "availableDate").value as! Int
                    let availableDate = Date(timeIntervalSince1970: TimeInterval(storedAvailableDate))
                    
                    // unpack contributor data from JSON child and package into 'Contributor' objects
                    var unpackedContributorsList: [Contributor] = []
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
                    
                    // package retrieved data into 'Album' objects
                    let unpackedAlbum = Album(
                        albumID: snap.key as! String,
                        ownerID: user.userID,
                        title: snap.childSnapshot(forPath: "title").value as! String,
                        description: snap.childSnapshot(forPath: "description").value as! String,
                        createdDate: createdDate,
                        availableDate: availableDate,
                        contributors: unpackedContributorsList,
                        coverURL: snap.childSnapshot(forPath: "coverURL").value as! String,
                        coverImage: nil,
                        isActive: snap.childSnapshot(forPath: "isActive").value as! Bool
                    )
                    if unpackedAlbum.isActive {
                        // synch local Album data with this server album instance !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        //unpackedActiveAlbums.append(unpackedAlbum)
                    } else {
                        unpackedInactiveAlbums.append(unpackedAlbum)
                    }
                    
                }
                // return packaged 'Album' objects
                self.fetchAlbumsDelegate?.didFetchAlbumsData(pastAlbums: unpackedInactiveAlbums, futureAlbums: unpackedActiveAlbums)
            }
        })
    }
    // [END get user albums from firebase]
    
    
    //-----
    

    // [START get a single user album from Firebase]
    func fetchSingleAlbumData(ownerID: String, albumID: String) {
        print ("Fetching single album from Firebase")
        
        // retrieve album data from Firebase
        let queryRef = mainDBRef.child("userAlbums").child(ownerID).child(albumID)
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // unpack album JSON data from Firebase
            let storedCreatedDate = snapshot.childSnapshot(forPath: "createdDate").value as! Int
            let createdDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
            let storedAvailableDate = snapshot.childSnapshot(forPath: "availableDate").value as! Int
            let availableDate = Date(timeIntervalSince1970: TimeInterval(storedAvailableDate))
            
            // unpack contributor data from JSON child and package into 'Contributor' objects
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
            
            // package retrieved data into 'Album' objects
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
                isActive: snapshot.childSnapshot(forPath: "isActive").value as! Bool
            )
            
            // return packaged 'Album' object
            self.fetchSingleAlbumDelegate?.didFetchSingleAlbum(album: unpackedAlbum)
        })
    }
    // [END get a single user album from Firebase]
    
    
    //-----
    

    // [START delete album]
    func deleteAlbum(album: Album) {
        
        // delete album data from Firebase database
        let albumRef = mainDBRef.child(Constants.FIR_USERALBUMS).child(album.ownerID).child(album.albumID)
        albumRef.removeValue { (error, ref) in
            if let error = error {
                print ("could not delete album data:\(error.localizedDescription)")
            } else {
                print ("album data deleted")
            }
        }
        
        // delete cover image from Firebase storage bucket
        let albumCoverRef = self.mainStorageRef.child(Constants.FIR_ALBUMCOVERS).child(album.ownerID).child(album.albumID)
        albumCoverRef.delete { (error) in
            if let error = error {
                print ("could not delete album cover: \(error.localizedDescription)")
            } else {
                print ("album cover deleted")
            }
        }
        
        // delete album media items from Firebase database
        let albumMediaDataRef = self.mainDBRef.child(Constants.FIR_ALBUMMEDIA).child(album.albumID)
        albumMediaDataRef.removeValue { (error, ref) in
            if let error = error {
                print ("could not delete album media data: \(error.localizedDescription)")
            } else {
                print ("album media data deleted")
            }
        }
        
        // delete album media items from Firebase storage bucket
        let albumMediaRef = self.mainStorageRef.child(Constants.FIR_ALBUMMEDIA).child(album.ownerID).child(album.albumID)
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
    
    
    
    //-------------------MANAGE MEDIA FUNCTIONS-----------------------------------------------------------
    
    // [START upload media to Firebase]
    // add a new media item to an album in firebase
    func uploadMediaToFirebase(media: UIImage, album: Album) {
        
        let currentUser = CurrentUser()
        let mediaID = "\(NSUUID().uuidString)" // create random ID for new media item
        
        // upload media item to Firebase storage bucket and get 'download url'
        guard let mediaData = UIImagePNGRepresentation(media) else { return }
        let mediaStorageRef = self.mainStorageRef.child(Constants.FIR_ALBUMMEDIA).child(album.albumID).child(mediaID)
        mediaStorageRef.put(mediaData, metadata: nil) { (metadata, error) in
            
            if let error = error { // upload error occurred - provide feedback
                print (error.localizedDescription)
            } else {
                
                // package media data into JSON object for Firebase database
                guard let mediaURL = metadata?.downloadURL()?.absoluteString else { return }
                let mediaData = [
                    "createdDate" : FIRServerValue.timestamp() as AnyObject,
                    "mediaID" : mediaID as AnyObject,
                    "mediaURL" : mediaURL as AnyObject,
                    "ownerID" : currentUser.userID as AnyObject
                ]
                
                // upload media item data to Firebase database
                let mediaDatabaseRef = self.mainDBRef.child(Constants.FIR_ALBUMMEDIA).child(album.albumID).child(mediaID)
                mediaDatabaseRef.updateChildValues(mediaData, withCompletionBlock: { (error, ref) in
                    if let error = error { // upload error occurred - provide feedback
                        print (error.localizedDescription)
                    } else { // callback once media upload complete
                        self.uploadMediaDelegate?.didUploadMedia()
                    }
                })
            }
        }
    }
    
    // [END upload media to Firebase]
    
    
    //------
    
    
    // [START commit media to album]
    
    // save a new media item to active album in local storage and attempt to save to corresponding album in firebase
    func commitMediaToAlbum(media: UIImage, album: Album) {
        
        let mediaOwner = CurrentUser()
        
        // save media to Core Data
        // implement save of media to CoreData here...
        
        // attempt to upload to firebase
        // uploadMediaToFirebase(media: media, album: album)...
    }
    
    // [END commit media to album]
    
    
    //-----
    
    
    // [START fetch media data]
    
    // get album media items from firebase/disk
    func fetchAlbumMedia(user: User, album: Album) {
        print ("Fetching album media from Firebase")
        var fetchedMedia = [Media]()
        
        // retrieve media from active albums on local disk
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
            
            // package retrieved media data into 'Media' objects
            for result in results {
                let media = Media(ownerID: user.userID, ownerUsername: user.username, mediaID: result.value(forKey: "mediaID") as! String, mediaURL: nil, image: result.value(forKey: "mediaItem") as! UIImage, createdDate: result.value(forKey: "createdDate") as! Date)
                fetchedMedia.append(media)
            }
            
            // return packaged Media objects
            self.fetchAlbumMediaDelegate?.didFetchAlbumMedia(fetchedMedia: fetchedMedia)
            
        } else { // retrieve media from inactive albums on Firebase
            
            // get number of media items in album
            var mediaCount = 0
            for contributor in album.contributors {
                mediaCount += contributor.photosTaken
            }
            
            // retrieve media data from Firebase
            let albumMediaRef = self.mainDBRef.child("albumMedia").child(album.albumID)
            albumMediaRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                // unpack media JSON data from Firebase
                if let allAlbumMedia = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for mediaItem in allAlbumMedia {
                        
                        var mediaID: String { return mediaItem.key }
                        let storedCreatedDate = mediaItem.childSnapshot(forPath: "createdDate").value as! Int
                        let mediaCreatedDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                        let mediaURL = mediaItem.childSnapshot(forPath: "mediaURL").value as? String
                        let ownerID = mediaItem.childSnapshot(forPath: "ownerID").value as? String
                    
                        // fetch media owner data from Firebase
                        let userRef = self.mainDBRef.child(Constants.FIR_USERS).child(ownerID!).child(Constants.FIR_PROFILE)
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            // unpack owner JSON data from Firebase
                            let mediaOwnerUsername = snapshot.childSnapshot(forPath: "username").value as! String
                            
                            // package retrieved media data into 'Media' objects
                            let fetchedMediaItem = Media(ownerID: ownerID!, ownerUsername: mediaOwnerUsername, mediaID: mediaID, mediaURL: mediaURL!, image: nil, createdDate: mediaCreatedDate)
                            fetchedMedia.append(fetchedMediaItem)
                            
                            // return packaged Media objects once album media count reached
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
    
    //-----
    
    // [START delete media]
    func deleteMedia(mediaURL: String) {
        let mediaStorageRef = mainStorageRef.child(Constants.FIR_ALBUMMEDIA).child(mediaURL)
        // implement delete image here...
    }
    // [END delete image]
    
    
    //-------------------MANAGE NOTIFICATIONS FUNCTIONS-----------------------------------------------------------
    
    // [START fetch notification data]
    
    // get current user notifications from firebase
    func fetchNotifications() {
        print ("fetching user notifications from Firebase")
        var fetchedNotifs = [UserNotification]()
        var notifsCount = 0
        let currentUser = CurrentUser()
        
        // retrieve notification data from Firebase
        let notifsRef = mainDBRef.child(Constants.FIR_USERNOTIFICATIONS).child(currentUser.userID)
        notifsRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            notifsCount = Int(snapshot.childrenCount) // update notifMax with number of items returned in the snapshot
            
            // unpack notification JSON data from Firebase
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    let notifObjectType = snap.childSnapshot(forPath: "objectType").value as! String
                    let notifAlbumID = snap.childSnapshot(forPath: "albumID").value as? String
                    let notifMediaID = snap.childSnapshot(forPath: "mediaID").value as? String
                    let notifType = snap.childSnapshot(forPath: "notifType").value as! String
                    let notifObjectOwnerID = snap.childSnapshot(forPath: "objectOwnerID").value as! String
                    let storedCreatedDate = snap.childSnapshot(forPath: "createdDate").value as! Int
                    let notifCreatedDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                    
                    // retrieve object's associated info //
                    let objectOwnerRef = self.mainDBRef.child(Constants.FIR_USERS).child(notifObjectOwnerID).child(Constants.FIR_PROFILE)
                    objectOwnerRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        // get object owner's username
                        guard let objectOwnerUsername = snapshot.childSnapshot(forPath: "username").value as? String else {
                            print ("could not fetch owner's username")
                            return
                        }
                        
                        // fetch object metadata from Firebase
                        switch notifObjectType {
                        case "album" :
                            let objectRef = self.mainDBRef.child(Constants.FIR_USERALBUMS).child(notifObjectOwnerID).child(notifAlbumID!)
                            objectRef.observe(.value, with: { (snapshot) in
                       
                                // unpack JSON data
                                guard let coverImageURL = snapshot.childSnapshot(forPath: "coverURL").value as? String else { return }
                                guard let albumTitle = snapshot.childSnapshot(forPath: "title").value as? String else { return }
                             
                                // fetch object image from Firebase storage bucket
                                let url = NSURL(string: coverImageURL)
                                var request = URLRequest(url: url as! URL)
                                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                    
                                    if error != nil { //download hit an error so return out
                                        print (error)
                                        return
                                    }
                                    
                                    DispatchQueue.main.async(execute: {
                                        if let downloadedImage = UIImage(data: data!) {
                                            
                                            // package fetched data into 'Notification' object
                                            let unpackedNotification = UserNotification(
                                                userID: currentUser.userID,
                                                createdDate: notifCreatedDate,
                                                notifType: notifType,
                                                objectType: notifObjectType,
                                                objectOwnerID: notifObjectOwnerID,
                                                objectOwnerUsername: objectOwnerUsername,
                                                albumID: notifAlbumID,
                                                mediaID: notifMediaID,
                                                title: albumTitle,
                                                image: downloadedImage
                                            )
                                            fetchedNotifs.append(unpackedNotification)
                                            
                                            // return packaged Notification objects once notifs count reached
                                            if fetchedNotifs.count == notifsCount {
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
                                
                                // unpack JSON data
                                if let mediaImageURL = snapshot.childSnapshot(forPath: "mediaURL").value as? String {
                                    
                                    // fetch object image from Firebase storage bucket
                                    let url = NSURL(string: mediaImageURL)
                                    var request = URLRequest(url: url as! URL)
                                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                        
                                        if error != nil { //download hit an error so let's return out
                                            print (error)
                                            return
                                        }
                                        
                                        DispatchQueue.main.async(execute: {
                                            if let downloadedImage = UIImage(data: data!) {
                                                
                                                // package fetched data into 'Notification' object
                                                let unpackedNotif = UserNotification(
                                                    userID: currentUser.userID,
                                                    createdDate: notifCreatedDate,
                                                    notifType: notifType,
                                                    objectType: notifType,
                                                    objectOwnerID: notifObjectOwnerID,
                                                    objectOwnerUsername: objectOwnerUsername,
                                                    albumID: notifAlbumID,
                                                    mediaID: notifMediaID,
                                                    title: nil,
                                                    image: downloadedImage
                                                )
                                                fetchedNotifs.append(unpackedNotif)
                                                
                                                // return packaged Notification objects once notifs count reached
                                                if fetchedNotifs.count == notifsCount {
                                                    self.fetchNotifsDelegate?.didFetchNotifs(fetchedNotifs: fetchedNotifs)
                                                }
                                            }
                                        })
                                    }
                                    task.resume()
                                    
                                }
                            })
                            return
                            
                            // cases for other object types go here
                            
                        default: break
                        }
                        
                    })
                }
            }
        }
    }
    
    // [END fetch notification data]
    
    
    
    //----------------MANAGING FILTERS FUNCTIONS----------------------------
    
    // [START Fetch Filters from local disk]
    static func fetchFilters () -> [Filter] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Filter")
    
        var filters: [Filter] = []
        
        // get filter data from CoreData
        let sectionSortDescriptor = [NSSortDescriptor(key: "lastSelected", ascending: false)]
        fetchRequest.sortDescriptors = sectionSortDescriptor
        do {
            if let fetchResults = try? managedContext?.fetch(fetchRequest) {
                
                // package filter data into 'Filter' objects
                for result in fetchResults! {
                    let name = result.value(forKey: "name") as? String
                    let lastSelected = result.value(forKey: "lastSelected") as? Date
                    let filter = Filter(name: name!, lastSelected: lastSelected!)
                    filters.append(filter)
                }
            }
        }
        
        // return fetched filter objects
        return filters
    }
    // [END Fetch Filters from local disk]
    
    //-----
    
    // [START update filter usage data]
    static func updateFilterInfo (filter: Filter) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // implement setting of 'last used' timestamp to current date/time
        //appDelegate.saveContext()
    }
    // [END update filter usage data]
    
    
    
}
