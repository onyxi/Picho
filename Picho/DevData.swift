//
//  DevData.swift
//  Picho
//
//  Created by Pete on 11/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import CoreData
import Foundation
import Firebase
import FirebaseDatabase

// Package and upload example data (albums, images, notifications) for new user - to Firebase and Core Data:
class DevData {
    private static let _instance = DevData()
    static var instance: DevData {
        return _instance
    }
    
    let constants = Constants()
    
    // get Firebase root references
    var mainDBRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var mainStorageRef: FIRStorageReference {
        return FIRStorage.storage().reference(forURL: "gs://picho-51f78.appspot.com")
    }
    
    
    
    // [START upload all data]
    func saveDevData() {
        print ("saving dev data")
        
        let owner = CurrentUser()
        
        // [START create example Album objects to save]
        
        // Create tuple to hold example album data
        let albums: [(title: String, description: String, created: String, available: String, remaining: Int, taken: Int, isActive: Bool)] = [
            
            // past albums
            (title: "Christmas",
             description: "The most wonderful time of the year!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 6,
             isActive: false),
            (title: "Holiday in Vegas",
             description: "Vegas Baby! Happy 4th of July!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 11,
             isActive: false),
            (title: "Summer Fun",
             description: "Time to relax",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 19,
             isActive: false),
            (title: "Fun with Friends",
             description: "Good times with good people...",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 8,
             isActive: false),
            (title: "The Rockies",
             description: "Mountain life at its best",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 23,
             isActive: false),
            (title: "Food Festival",
             description: "A day of culinary delights",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 15,
             isActive: false),
            (title: "Honeymoon",
             description: "Magical times with my better half",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 15,
             isActive: false),
            (title: "Weekend Break",
             description: "How much fun can you have in 48 hours?",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 20,
             isActive: false),
            (title: "Country Life",
             description: "Back to roots, and a breath of fresh air!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 5,
             isActive: false),
            (title: "Olympic Games",
             description: "Celebrating life at Rio 2016",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 9,
             isActive: false),
            (title: "India",
             description: "Finding ourselves - in the sub-continent",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 8,
             isActive: false),
            (title: "Family Hols",
             description: "Time to catch up with the fam",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 8,
             isActive: false),
            (title: "Birthday Party",
             description: "You only live once!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 5,
             isActive: false),
            (title: "Safari",
             description: "A short walk in the Serengeti",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 6,
             isActive: false),
            (title: "NYE",
             description: "Happy New Year!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 4,
             isActive: false),
            (title: "New Zealand",
             description: "The end of the earth!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 5,
             isActive: false),
            (title: "Indonesia",
             description: "4 months in paradise",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 0,
             taken: 6,
             isActive: false),
            
            
            // active albums
            (title: "Jim's Wedding",
             description: "What a day!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 14,
             taken: 7,
             isActive: true),
            (title: "Music Festival",
             description: "This is going to Rock!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 19,
             taken: 7,
             isActive: true),
            (title: "Travels",
             description: "The trip of a lifetime",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 58,
             taken: 6,
             isActive: true),
            (title: "The Boys",
             description: "They grow up so fast!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 46,
             taken: 3,
             isActive: true),
            (title: "Martha",
             description: "What a beauty!",
             created: "1493760824992",
             available: "1493760824992",
             remaining: 52,
             taken: 2,
             isActive: true)
        ]
        
        // package Album objects to be saved
        var albumIndex = 0
        for album in albums {
            
            var albumCode = ""
            
            switch albumIndex {
            case 0:
                albumCode = "christmas"
            case 1:
                albumCode = "vegas"
            case 2:
                albumCode = "summer"
            case 3:
                albumCode = "friends"
            case 4:
                albumCode = "rockies"
            case 5:
                albumCode = "food"
            case 6:
                albumCode = "honeymoon"
            case 7:
                albumCode = "weekend"
            case 8:
                albumCode = "country"
            case 9:
                albumCode = "olympics"
            case 10:
                albumCode = "india"
            case 11:
                albumCode = "family"
            case 12:
                albumCode = "birthday"
            case 13:
                albumCode = "safari"
            case 14:
                albumCode = "NY"
            case 15:
                albumCode = "NZ"
            case 16:
                albumCode = "indo"
                
            case 17:
                albumCode = "wedding"
            case 18:
                albumCode = "festival"
            case 19:
                albumCode = "travels"
            case 20:
                albumCode = "boys"
            case 21:
                albumCode = "martha"
            default:
                break
            }
            
            
            
            guard let cover = UIImage(named: "\(albumCode)Cover") else { return }
            
            guard let coverData = UIImagePNGRepresentation(cover) else { return }
            
            let albumID = "\(NSUUID().uuidString)"
            
            let createdDate = Date(timeIntervalSince1970: TimeInterval(album.created)!)
            let availableDate = Date(timeIntervalSince1970: TimeInterval(album.available)!)
            
            let album = Album(
                albumID: albumID,
                ownerID: owner.userID,
                title: album.title,
                description: album.description,
                createdDate: createdDate,
                availableDate: availableDate,
                contributors: [Contributor(
                    userID: owner.userID,
                    username: owner.username,
                    photosRemaining: album.remaining,
                    photosTaken: album.taken)
                ],
                coverURL: nil,
                coverImage: cover,
                isActive: album.isActive
            )
            
            // [END create example Album objects to save]
            
            // **
            
            // [START save active albums to Core Data]
            
            // if album is active save to Core Data
            if album.isActive == true {
                
                // package and save Album objects to Core Data
                guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.managedObjectContext
                let entity = NSEntityDescription.entity(forEntityName: "ActiveAlbum", in: managedContext)
                let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
                objectToSave.setValue(album.albumID, forKey: "albumID")
                objectToSave.setValue(album.ownerID, forKey: "ownerID")
                objectToSave.setValue(album.coverImage, forKey: "coverImage")
                objectToSave.setValue(album.title, forKey: "titleText")
                objectToSave.setValue(album.description, forKey: "descriptionText")
                objectToSave.setValue(createdDate, forKey: "createdDate")
                objectToSave.setValue(availableDate, forKey: "availableDate")
                objectToSave.setValue(Date(), forKey: "lastSelected")
                objectToSave.setValue(true, forKey: "isActive")
                objectToSave.setValue(false, forKey: "synchedToFirebase")
                objectToSave.setValue(false, forKey: "firstSynchComplete")
                
                do { try managedContext.save() } catch {}
                
                // package and save Contributor objects to Core Data
                var photosTakenCount = 0
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
                    
                    photosTakenCount += contributor.photosTaken
                    
                }
                
                // package and save Media objects to Core Data
                for media in 1 ... photosTakenCount {
                    let mediaID = NSUUID().uuidString
                    let media = UIImage(named: "\(albumCode)\(media)")
                    
                    let managedContext = appDelegate.managedObjectContext
                    let entity = NSEntityDescription.entity(forEntityName: "Media", in: managedContext)
                    let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
                    objectToSave.setValue(mediaID, forKey: "mediaID")
                    objectToSave.setValue(media, forKey: "mediaItem")
                    objectToSave.setValue(album.albumID, forKey: "albumID")
                    objectToSave.setValue(Date(), forKey: "createdDate")
                    
                    do { try managedContext.save() } catch {}
                }
                
            }
            
            // [END save active albums to Core Data]
            
            // **
            
            // [START upload all example albums to Firebase]
            
            // upload cover image and get download url
            let coverRef = self.mainStorageRef.child(self.constants.FIRS_ALBUMCOVERS).child(album.ownerID).child(albumID)
            coverRef.put(coverData, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
                if error != nil {
                    print (error?.localizedDescription as Any)
                    return
                }
                if let coverDownloadURL = metadata?.downloadURL()?.absoluteString {
                    
                    // package album object as JSON object for Firebase
                    let albumData = [
                        "coverURL" : coverDownloadURL as AnyObject,
                        "title" : album.title as AnyObject,
                        "description" : album.description as AnyObject,
                        "createdDate" : FIRServerValue.timestamp() as AnyObject,
                        "availableDate" : (album.availableDate.timeIntervalSince1970 * 1000).rounded() as AnyObject,
                        "isActive" : album.isActive as AnyObject
                    ]
                    
                    // save album as Firebase album node
                    let albumRef = self.mainDBRef.child(self.constants.FIRD_USERALBUMS).child("\(album.ownerID)").child(albumID)
                    albumRef.updateChildValues(albumData, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print (error?.localizedDescription as Any)
                        } else {
                            print ("new album added")
                        }
                    })
                    
                    // re-package contributors list as JSON object for Firebase
                    var contributorsList: Dictionary<String, AnyObject> = [:]
                    var mediaCount = 0
                    for contributor in album.contributors {
                        let contributorData: Dictionary<String, AnyObject> = [
                            "username": contributor.username as AnyObject,
                            "photosRemaining": contributor.photosRemaining as AnyObject,
                            "photosTaken": contributor.photosTaken as AnyObject
                        ]
                        
                        let contributorID = contributor.userID
                        contributorsList["\(contributorID)"] = contributorData as AnyObject?
                        
                        mediaCount += contributor.photosTaken
                        
                    }
                    
                    // save album contributors as Firebase album node
                    let contributorsRef = albumRef.child(self.constants.FIRD_CONTRIBUTORS)
                    contributorsRef.updateChildValues(contributorsList, withCompletionBlock: { (error: Error?, ref) in
                        if error != nil {
                            print (error?.localizedDescription as Any)
                        } else {
                            
                            self.uploadImagesToFirebase(owner: owner, albumID: albumID, albumCode: albumCode, mediaCount: mediaCount)
                            
                        }
                    })
                    
                    // [END upload all example albums to Firebase]
                    
                    // *
                    
                    // [START create example notifications]
                    
                    // if album is not active create a notification in firebase - to say the album is now available to view
                    if !album.isActive {
                        let notifData = [
                            "albumID": albumID as AnyObject,
                            "createdDate": FIRServerValue.timestamp() as AnyObject,
                            "notifType": "albumReady" as AnyObject,
                            "objectOwnerID": album.ownerID as AnyObject,
                            "objectType": "album" as AnyObject
                        ]
                        let notifID = NSUUID().uuidString
                        let notifRef = self.mainDBRef.child(self.constants.FIRD_USERNOTIFICATIONS).child(album.ownerID).child(notifID)
                        notifRef.updateChildValues(notifData, withCompletionBlock: { (error, ref) in
                            if let error = error {
                                print (error.localizedDescription)
                            } else {
                                print ("notification uploaded")
                            }
                        })
                    }
                    // [END create example notifications]
                }
            })
            
            albumIndex += 1
        }
        // [END uploading albums
        
    }
    
    
    // [START uploading images]
    func uploadImagesToFirebase(owner: User, albumID: String, albumCode: String, mediaCount: Int) {
        print("Uploading images to Firebase")
        
        let ownerRef = owner.userID
        
        for mediaNumber in 1...mediaCount {
            
            guard let media = UIImage(named: "\(albumCode)\(mediaNumber)") else { return }
            guard let mediaDataObject = UIImagePNGRepresentation(media) else { return }
            
            let mediaID = NSUUID().uuidString
            let mediaObjectRef = mainStorageRef.child(self.constants.FIRS_ALBUMMEDIA).child(albumID).child(mediaID)
            
            mediaObjectRef.put(mediaDataObject, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print (error?.localizedDescription as Any)
                } else {
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                        let mediaDataRef = self.mainDBRef.child(self.constants.FIRD_ALBUMMEDIA).child(albumID).child(mediaID)
                        let mediaData = [
                            "createdDate" : FIRServerValue.timestamp() as AnyObject,
                            "mediaURL" : downloadURL as AnyObject,
                            "mediaID" : mediaID as AnyObject,
                            "ownerID" : ownerRef as AnyObject
                        ]
                        
                        mediaDataRef.updateChildValues(mediaData, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print (error?.localizedDescription as Any)
                            } else {
                                print ("media uploaded")
                            }
                        })
                        
                    }
                }
            })
            
        }
        
    }
    // [END uploading images]
    
    // [END upload all data]
    
    // **
    
    // Manual override of 'CurrentUser' data for use in development :
    func setCurrentUserData() {
        UserDefaults.standard.set("doFNiHlxHlZw7RS3Yajl4bqREjg2", forKey: constants.CURRENTUSER_ID)
        UserDefaults.standard.set("jim@picho.com", forKey: constants.CURRENTUSER_USERNAME)
        UserDefaults.standard.set("jim@picho.com", forKey: constants.CURRENTUSER_EMAIL)
        UserDefaults.standard.set("password", forKey: constants.CURRENTUSER_PASSWORD)
        UserDefaults.standard.set("https://firebasestorage.googleapis.com/v0/b/picho-51f78.appspot.com/o/userMedia%2FPHprofileImage.jpg?alt=media&token=b4e5e291-375a-4c50-bf13-27c0f6105144", forKey: constants.CURRENTUSER_PROFILEPICURL)
    }
    
}
