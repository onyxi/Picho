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
    
    let constants = Constants()
    
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
                    let profile: Dictionary<String, AnyObject> = [
                        self.constants.FIRD_USERS_EMAIL: email as AnyObject,
                        self.constants.FIRD_USERS_PASSWORD : password as AnyObject,
                        self.constants.FIRD_USERS_USERNAME: email as AnyObject,
                        self.constants.FIRD_USERS_PROFILEPICURL : "placeholder" as AnyObject
                    ]
                    self.mainDBRef.child(self.constants.FIRD_USERS).child((user?.uid)!).setValue(profile)
                    
                    // log in to FB account with credentials
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                        if error != nil {
                            
                            // could not log in - show error to user
                            self.handleFirebaseAuthError(error: error! as NSError, onComplete: onComplete)
        
                        }
                        
                        // store user's data on disk and in memory
                        UserDefaults.standard.set(user?.uid, forKey: self.constants.CURRENTUSER_ID)
                        UserDefaults.standard.set(email, forKey: self.constants.CURRENTUSER_USERNAME)
                        UserDefaults.standard.set(email, forKey: self.constants.CURRENTUSER_EMAIL)
                        UserDefaults.standard.set(password, forKey: self.constants.CURRENTUSER_PASSWORD)
                        UserDefaults.standard.set("placeholder", forKey: self.constants.CURRENTUSER_PROFILEPICURL)
                        UserDefaults.standard.set(true, forKey: self.constants.CURRENTUSER_ISLOADED)

                        
                        // [START load default data to firebase database/storage bucket]
                        // DevData.instance.saveDevData()
                        
                        // implement showing of 'loading, please wait' message
                        
                            // once complete:
                            // we have successfully logged in - return user data to caller
                            onComplete?(nil, user)
                        
                        // [END load default data to firebase database/storage bucket]
                        
                        // call back to fetch user data
                        self.authenticateDelegate?.didAuthenticate() // is this necessary?
                        
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
                let userRef = self.mainDBRef.child(self.constants.FIRD_USERS).child(userID!)
             //   userRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // unpack user's data
                    if let userData = snapshot.value as? [String : AnyObject] {
                        for loggedInUser in userData {
                            let email = loggedInUser.value[self.constants.FIRD_USERS_EMAIL] as! String
                            let password = loggedInUser.value[self.constants.FIRD_USERS_PASSWORD] as! String
                            print (password)
                            let username = loggedInUser.value[self.constants.FIRD_USERS_USERNAME] as! String
                            let profilePicURL = loggedInUser.value[self.constants.FIRD_USERS_PROFILEPICURL] as! String
                            
                            // store user's data in memory
                            UserDefaults.standard.set(userID, forKey: self.constants.CURRENTUSER_ID)
                            UserDefaults.standard.set(username, forKey: self.constants.CURRENTUSER_USERNAME)
                            UserDefaults.standard.set(email, forKey: self.constants.CURRENTUSER_EMAIL)
                            UserDefaults.standard.set(password, forKey: self.constants.CURRENTUSER_PASSWORD)
                            UserDefaults.standard.set(profilePicURL, forKey: self.constants.CURRENTUSER_PROFILEPICURL)
                            UserDefaults.standard.set(true, forKey: self.constants.CURRENTUSER_ISLOADED)
                            
                            // call back to fetch user data
                            self.authenticateDelegate?.didAuthenticate()
                            
                            // we have successfully logged in - return user data to caller
                            onComplete?(nil, user)
                            
                        }
                    }
                })
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
            
            UserDefaults.standard.set(nil, forKey: constants.CURRENTUSER_ID)
            UserDefaults.standard.set(nil, forKey: constants.CURRENTUSER_EMAIL)
            UserDefaults.standard.set(nil, forKey: constants.CURRENTUSER_USERNAME)
            UserDefaults.standard.set(nil, forKey: constants.CURRENTUSER_PASSWORD)
            UserDefaults.standard.set(nil, forKey: constants.CURRENTUSER_PROFILEPICURL)
            UserDefaults.standard.set(false, forKey: constants.CURRENTUSER_ISLOADED)

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
            let entity = NSEntityDescription.entity(forEntityName: self.constants.CD_ACTIVEALBUM, in: managedContext)
            let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
            objectToSave.setValue(album.albumID, forKey: self.constants.CD_ACTIVEALBUM_ALBUMID)
            objectToSave.setValue(album.ownerID, forKey: self.constants.CD_ACTIVEALBUM_OWNERID)
            objectToSave.setValue(album.coverImage, forKey: self.constants.CD_ACTIVEALBUM_COVERIMAGE)
            objectToSave.setValue(album.title, forKey: self.constants.CD_ACTIVEALBUM_TITLETEXT)
            objectToSave.setValue(album.description, forKey: self.constants.CD_ACTIVEALBUM_DESCRIPTIONTEXT)
            objectToSave.setValue(album.createdDate, forKey: self.constants.CD_ACTIVEALBUM_CREATEDDATE)
            objectToSave.setValue(album.availableDate, forKey: self.constants.CD_ACTIVEALBUM_AVAILABLEDATE)
            objectToSave.setValue(Date(), forKey: self.constants.CD_ACTIVEALBUM_LASTSELECTED)
            objectToSave.setValue(true, forKey: self.constants.CD_ACTIVEALBUM_ISACTIVE)
            objectToSave.setValue(true, forKey: self.constants.CD_ACTIVEALBUM_SYNCHEDTOFIREBASE)
            objectToSave.setValue(true, forKey: self.constants.CD_ACTIVEALBUM_FIRSTSYNCHCOMPLETE)
            
            // unpack Contributor objects and save to CoreData
            for contributor in album.contributors {
                let managedContext = appDelegate.managedObjectContext
                let entity = NSEntityDescription.entity(forEntityName: self.constants.CD_CONTRIBUTOR, in: managedContext)
                let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
                objectToSave.setValue(album.albumID, forKey: self.constants.CD_CONTRIBUTOR_ALBUMID)
                objectToSave.setValue(contributor.userID, forKey: self.constants.CD_CONTRIBUTOR_USERID)
                objectToSave.setValue(contributor.username, forKey: self.constants.CD_CONTRIBUTOR_USERNAME)
                objectToSave.setValue(contributor.photosRemaining, forKey: self.constants.CD_CONTRIBUTOR_MEDIAREMAINING)
                objectToSave.setValue(contributor.photosTaken, forKey: self.constants.CD_CONTRIBUTOR_MEDIATAKEN)
                
                do { try managedContext.save() } catch {}
                
            }
            
            do { try managedContext.save() } catch {}
        }
        
        // upload album cover image to Firebase storage and return 'download url'
        guard let cover = album.coverImage else { return }
        guard let coverData = UIImagePNGRepresentation(cover) else { return }
        let coverRef = self.mainStorageRef.child(self.constants.FIRS_ALBUMCOVERS).child(album.ownerID).child(albumID)
        coverRef.put(coverData, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
            if error != nil { // upload error occurred - provide feedback
                print (error?.localizedDescription as Any)
                return
            }
            if let coverDownloadURL = metadata?.downloadURL()?.absoluteString {
                
                // package 'contributors' data as JSON object for Firebase
                var contributorsList: Dictionary<String, AnyObject> = [:]
                for contributor in album.contributors {
                    let contributorData: Dictionary<String, AnyObject> = [
                        self.constants.FIRD_CONTRIBUTORS_USERNAME: contributor.username as AnyObject,
                        self.constants.FIRD_CONTRIBUTORS_PHOTOSREMAINING: contributor.photosRemaining as AnyObject,
                        self.constants.FIRD_CONTRIBUTORS_PHOTOSTAKEN: contributor.photosTaken as AnyObject
                    ]
                    
                    let contributorID = contributor.userID
                    contributorsList["\(contributorID)"] = contributorData as AnyObject?
                    
                }
                
                // package 'album' data as JSON object for Firebase
                let albumData = [
                    self.constants.FIRD_USERALBUMS_COVERURL : coverDownloadURL as AnyObject,
                    self.constants.FIRD_USERALBUMS_TITLE : album.title as AnyObject,
                    self.constants.FIRD_USERALBUMS_DESCRIPTION : album.description as AnyObject,
                    self.constants.FIRD_USERALBUMS_CREATEDDATE : FIRServerValue.timestamp() as AnyObject,
                    self.constants.FIRD_USERALBUMS_AVAILABLEDATE : (album.availableDate.timeIntervalSince1970 * 1000).rounded() as AnyObject,
                    self.constants.FIRD_USERALBUMS_ISACTIVE : album.isActive as AnyObject,
                    self.constants.FIRD_USERALBUMS_CONTRIBUTORS : contributorsList as AnyObject
                ]
                
                // upload album data to Firebase database
                let albumRef = self.mainDBRef.child(self.constants.FIRD_USERALBUMS).child(album.ownerID).child(albumID)
                albumRef.updateChildValues(albumData, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print (error?.localizedDescription as Any)
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
        let queryRef = mainDBRef.child(constants.FIRD_USERALBUMS).child(user.userID).queryOrdered(byChild: self.constants.FIRD_USERALBUMS_TITLE)
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // unpack album JSON data from Firebase
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    let storedCreatedDate = snap.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_CREATEDDATE).value as! Int
                    let createdDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                    let storedAvailableDate = snap.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_AVAILABLEDATE).value as! Int
                    let availableDate = Date(timeIntervalSince1970: TimeInterval(storedAvailableDate))
                    
                    // unpack contributor data from JSON child and package into 'Contributor' objects
                    var unpackedContributorsList: [Contributor] = []
                    if let contributorsDict = snap.childSnapshot(forPath: self.constants.FIRD_CONTRIBUTORS).value as? [String: AnyObject] {
                        for contributor in contributorsDict {
                            let unpackedContributor = Contributor(
                                userID: contributor.key,
                                username: contributor.value[self.constants.FIRD_CONTRIBUTORS_USERNAME] as! String,
                                photosRemaining: contributor.value[self.constants.FIRD_CONTRIBUTORS_PHOTOSREMAINING] as! Int,
                                photosTaken: contributor.value[self.constants.FIRD_CONTRIBUTORS_PHOTOSTAKEN] as! Int
                            )
                            unpackedContributorsList.append(unpackedContributor)
                        }
                    }
                    
                    // package retrieved data into 'Album' objects
                    let unpackedAlbum = Album(
                        albumID: snap.key,
                        ownerID: user.userID,
                        title: snap.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_TITLE).value as! String,
                        description: snap.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_DESCRIPTION).value as! String,
                        createdDate: createdDate,
                        availableDate: availableDate,
                        contributors: unpackedContributorsList,
                        coverURL: snap.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_COVERURL).value as? String,
                        coverImage: nil,
                        isActive: snap.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_ISACTIVE).value as! Bool
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
        let queryRef = mainDBRef.child(self.constants.FIRD_USERALBUMS).child(ownerID).child(albumID)
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // unpack album JSON data from Firebase
            let storedCreatedDate = snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_CREATEDDATE).value as! Int
            let createdDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
            let storedAvailableDate = snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_AVAILABLEDATE).value as! Int
            let availableDate = Date(timeIntervalSince1970: TimeInterval(storedAvailableDate))
            
            // unpack contributor data from JSON child and package into 'Contributor' objects
            var unpackedContributorsList: [Contributor] = []
            if let contributorsDict = snapshot.childSnapshot(forPath: self.constants.FIRD_CONTRIBUTORS).value as? [String: AnyObject] {
                for contributor in contributorsDict {
                    let unpackedContributor = Contributor(
                        userID: contributor.key,
                        username: contributor.value[self.constants.FIRD_CONTRIBUTORS_USERNAME] as! String,
                        photosRemaining: contributor.value[self.constants.FIRD_CONTRIBUTORS_PHOTOSREMAINING] as! Int,
                        photosTaken: contributor.value[self.constants.FIRD_CONTRIBUTORS_PHOTOSTAKEN] as! Int
                    )
                    unpackedContributorsList.append(unpackedContributor)
                }
            }
            
            // package retrieved data into 'Album' objects
            let unpackedAlbum = Album(
                albumID: albumID,
                ownerID: ownerID,
                title: snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_TITLE).value as! String,
                description: snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_DESCRIPTION).value as! String,
                createdDate: createdDate,
                availableDate: availableDate,
                contributors: unpackedContributorsList,
                coverURL: snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_COVERURL).value as? String,
                coverImage: nil,
                isActive: snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_ISACTIVE).value as! Bool
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
        let albumRef = mainDBRef.child(constants.FIRD_USERALBUMS).child(album.ownerID).child(album.albumID)
        albumRef.removeValue { (error, ref) in
            if let error = error {
                print ("could not delete album data:\(error.localizedDescription)")
            } else {
                print ("album data deleted")
            }
        }
        
        // delete cover image from Firebase storage bucket
        let albumCoverRef = self.mainStorageRef.child(constants.FIRS_ALBUMCOVERS).child(album.ownerID).child(album.albumID)
        albumCoverRef.delete { (error) in
            if let error = error {
                print ("could not delete album cover: \(error.localizedDescription)")
            } else {
                print ("album cover deleted")
            }
        }
        
        // delete album media items from Firebase database
        let albumMediaDataRef = self.mainDBRef.child(constants.FIRD_ALBUMMEDIA).child(album.albumID)
        albumMediaDataRef.removeValue { (error, ref) in
            if let error = error {
                print ("could not delete album media data: \(error.localizedDescription)")
            } else {
                print ("album media data deleted")
            }
        }
        
        // delete album media items from Firebase storage bucket
        let albumMediaRef = self.mainStorageRef.child(constants.FIRS_ALBUMMEDIA).child(album.ownerID).child(album.albumID)
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
        let mediaStorageRef = self.mainStorageRef.child(constants.FIRS_ALBUMMEDIA).child(album.albumID).child(mediaID)
        mediaStorageRef.put(mediaData, metadata: nil) { (metadata, error) in
            
            if let error = error { // upload error occurred - provide feedback
                print (error.localizedDescription)
            } else {
                
                // package media data into JSON object for Firebase database
                guard let mediaURL = metadata?.downloadURL()?.absoluteString else { return }
                let mediaData = [
                    self.constants.FIRD_ALBUMMEDIA_CREATEDDATE : FIRServerValue.timestamp() as AnyObject,
                    self.constants.FIRD_ALBUMMEDIA_MEDIAID : mediaID as AnyObject,
                    self.constants.FIRD_ALBUMMEDIA_MEDIAURL : mediaURL as AnyObject,
                    self.constants.FIRD_ALBUMMEDIA_OWNERID : currentUser.userID as AnyObject
                ]
                
                // upload media item data to Firebase database
                let mediaDatabaseRef = self.mainDBRef.child(self.constants.FIRD_ALBUMMEDIA).child(album.albumID).child(mediaID)
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
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.constants.CD_MEDIA)
            var results: [NSManagedObject] = []
            
            let predicate = NSPredicate(format: "%K == %@", self.constants.CD_MEDIA_ALBUMID, album.albumID)
            fetchRequest.predicate = predicate
            
            let sectionSortDescriptor = [NSSortDescriptor(key: self.constants.CD_MEDIA_CREATEDDATE, ascending: true)]
            fetchRequest.sortDescriptors = sectionSortDescriptor
            
            do {
                if let fetchResult = try? managedContext?.fetch(fetchRequest) {
                    results = fetchResult!
                }
            }
            
            // package retrieved media data into 'Media' objects
            for result in results {
                let media = Media(ownerID: user.userID, ownerUsername: user.username, mediaID: result.value(forKey: self.constants.CD_MEDIA_MEDIAID) as! String, mediaURL: nil, image: result.value(forKey: self.constants.CD_MEDIA_MEDIAITEM) as? UIImage, createdDate: result.value(forKey: self.constants.CD_MEDIA_CREATEDDATE) as! Date)
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
            let albumMediaRef = self.mainDBRef.child(self.constants.FIRD_ALBUMMEDIA).child(album.albumID)
            albumMediaRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                // unpack media JSON data from Firebase
                if let allAlbumMedia = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for mediaItem in allAlbumMedia {
                        
                        var mediaID: String { return mediaItem.key }
                        let storedCreatedDate = mediaItem.childSnapshot(forPath: self.constants.FIRD_ALBUMMEDIA_CREATEDDATE).value as! Int
                        let mediaCreatedDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                        let mediaURL = mediaItem.childSnapshot(forPath: self.constants.FIRD_ALBUMMEDIA_MEDIAURL).value as? String
                        let ownerID = mediaItem.childSnapshot(forPath: self.constants.FIRD_ALBUMMEDIA_OWNERID).value as? String
                    
                        // fetch media owner data from Firebase
                        let userRef = self.mainDBRef.child(self.constants.FIRD_USERS).child(ownerID!)
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            // unpack owner JSON data from Firebase
                            let mediaOwnerUsername = snapshot.childSnapshot(forPath: self.constants.FIRD_USERS_USERNAME).value as! String
                            
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
        let mediaStorageRef = mainStorageRef.child(constants.FIRS_ALBUMMEDIA).child(mediaURL)
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
        let notifsRef = mainDBRef.child(constants.FIRD_USERNOTIFICATIONS).child(currentUser.userID)
        notifsRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            notifsCount = Int(snapshot.childrenCount) // update notifMax with number of items returned in the snapshot
            
            // unpack notification JSON data from Firebase
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    let notifObjectType = snap.childSnapshot(forPath: self.constants.FIRD_USERNOTIFICATIONS_OBJECTTYPE ).value as! String
                    let notifAlbumID = snap.childSnapshot(forPath: self.constants.FIRD_USERNOTIFICATIONS_ALBUMID).value as? String
                    let notifMediaID = snap.childSnapshot(forPath: self.constants.FIRD_USERNOTIFICATIONS_MEDIAID).value as? String
                    let notifType = snap.childSnapshot(forPath: self.constants.FIRD_USERNOTIFICATIONS_NOTIFTYPE).value as! String
                    let notifObjectOwnerID = snap.childSnapshot(forPath: self.constants.FIRD_USERNOTIFICATIONS_OBJECTOWNERID).value as! String
                    let storedCreatedDate = snap.childSnapshot(forPath: self.constants.FIRD_USERNOTIFICATIONS_CREATEDDATE).value as! Int
                    let notifCreatedDate = Date(timeIntervalSince1970: TimeInterval(storedCreatedDate))
                    
                    // retrieve object's associated info //
                    let objectOwnerRef = self.mainDBRef.child(self.constants.FIRD_USERS).child(notifObjectOwnerID)
                    objectOwnerRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        // get object owner's username
                        guard let objectOwnerUsername = snapshot.childSnapshot(forPath: self.constants.FIRD_USERS_USERNAME).value as? String else {
                            print ("could not fetch owner's username")
                            return
                        }
                        
                        // fetch object metadata from Firebase
                        switch notifObjectType {
                        case "album" :
                            let objectRef = self.mainDBRef.child(self.constants.FIRD_USERALBUMS).child(notifObjectOwnerID).child(notifAlbumID!)
                            objectRef.observe(.value, with: { (snapshot) in
                       
                                // unpack JSON data
                                guard let coverImageURL = snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_COVERURL).value as? String else { return }
                                guard let albumTitle = snapshot.childSnapshot(forPath: self.constants.FIRD_USERALBUMS_TITLE).value as? String else { return }
                             
                                // fetch object image from Firebase storage bucket
                                let url = NSURL(string: coverImageURL)
                                let request = URLRequest(url: url! as URL)
                                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                    
                                    if error != nil { //download hit an error so return out
                                        print (error?.localizedDescription as Any)
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
                            let objectRef = self.mainDBRef.child(self.constants.FIRD_ALBUMMEDIA).child(notifAlbumID!).child(notifMediaID!)
                            objectRef.observe(.value, with: { (snapshot) in
                                
                                // unpack JSON data
                                if let mediaImageURL = snapshot.childSnapshot(forPath: self.constants.FIRD_ALBUMMEDIA_MEDIAURL).value as? String {
                                    
                                    // fetch object image from Firebase storage bucket
                                    let url = NSURL(string: mediaImageURL)
                                    let request = URLRequest(url: url! as URL)
                                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                        
                                        if error != nil { //download hit an error so let's return out
                                            print (error?.localizedDescription as Any)
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
    func fetchFilters () -> [Filter] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.constants.CD_FILTER)
    
        var filters: [Filter] = []
        
        // get filter data from CoreData
        let sectionSortDescriptor = [NSSortDescriptor(key: self.constants.CD_FILTER_LASTSELECTED, ascending: false)]
        fetchRequest.sortDescriptors = sectionSortDescriptor
        do {
            if let fetchResults = try? managedContext?.fetch(fetchRequest) {
                
                // package filter data into 'Filter' objects
                for result in fetchResults! {
                    let name = result.value(forKey: self.constants.CD_FILTER_NAME) as? String
                    let lastSelected = result.value(forKey: self.constants.CD_FILTER_LASTSELECTED) as? Date
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
