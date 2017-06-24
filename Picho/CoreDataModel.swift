//
//  CoreDataModel.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 23/11/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import Foundation
import CoreData


class CoreDataModel {
    
    var managedContext: NSManagedObjectContext?
    var dateFmt = DateFormatter()
    
    init () {
        
        
        dateFmt.timeZone = NSTimeZone.default
        dateFmt.dateFormat =  "dd-MM-yyyy"
    }

    
    ///////////////Saving//////////////////////
    
    static func saveCurrentUser(userID: String, username: String, email: String, password: String, profileImage: UIImage){
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "CurrentUser", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(userID, forKey: "userID")
        objectToSave.setValue(username, forKey: "username")
        objectToSave.setValue(email, forKey: "email")
        objectToSave.setValue(password, forKey: "password")
        objectToSave.setValue(profileImage, forKey: "profileImage")
        
        do { try managedContext.save() } catch {}
        
    }
    
    
    
    
    
    
    static func newActiveAlbum(coverImage: UIImage, titleText: String, descriptionText: String, availableDate: Date, contributors: [Contributor]) {
        let albumID = NSUUID().uuidString
        let currentUser = CurrentUser()
        
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "ActiveAlbum", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(albumID, forKey: "albumID")
        objectToSave.setValue(currentUser.userID, forKey: "ownerID")
        objectToSave.setValue(coverImage, forKey: "coverImage")
        objectToSave.setValue(titleText, forKey: "titleText")
        objectToSave.setValue(descriptionText, forKey: "descriptionText")
        objectToSave.setValue(Date(), forKey: "createdDate")
        objectToSave.setValue(availableDate, forKey: "availableDate")
        objectToSave.setValue(Date(), forKey: "lastSelected")
        objectToSave.setValue(true, forKey: "isActive")
        objectToSave.setValue(false, forKey: "synchedToFirebase")
        objectToSave.setValue(false, forKey: "firstSynchComplete")
        
        for contributor in contributors {
            let managedContext = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Contributor", in: managedContext)
            let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
            objectToSave.setValue(albumID, forKey: "albumID")
            objectToSave.setValue(contributor.userID, forKey: "userID")
            objectToSave.setValue(contributor.username, forKey: "username")
            objectToSave.setValue(contributor.photosRemaining, forKey: "mediaRemaining")
            objectToSave.setValue(contributor.photosTaken, forKey: "mediaTaken")
            
            do { try managedContext.save() } catch {}
            
        }
        
        // attempt synch to firebase
        //FBService().createNewAlbum(title: titleText, description: descriptionText, availableDate: availableDate, coverImage: coverImage, contributors: contributors)
        
    }
    
    static func saveActiveAlbum(album: Album) {
        
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
    
    
    
    static func saveMediaToAlbum(album: Album, media: UIImage) {
        
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "ActiveAlbum", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(media, forKey: "mediaItem")
        objectToSave.setValue(NSUUID().uuidString, forKey: "mediaID")
        objectToSave.setValue(album.albumID, forKey: "albumID")
        
        do { try managedContext.save() } catch {}
        
        // attempt to synch to firebase
        FBService().uploadMediaToFirebase(media: media, album: album)
        
    }
    
    
    /////////// fetching
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    // Save Album
//    static func saveAlbum (title: String, albumDescription: String, owner: String, dateCreated: Date, dateAvailable: Date, isAvailable: Bool, photosTaken: Int, photosRemaining: Int, lastSelected: Date ) {
//        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appDelegate.managedObjectContext
//        let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedContext)
//        
//        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
//        objectToSave.setValue(title, forKey: "title")
//        objectToSave.setValue(albumDescription, forKey: "albumDescription")
//        objectToSave.setValue(owner, forKey: "owner")
//        objectToSave.setValue(dateCreated, forKey: "dateCreated")
//        objectToSave.setValue(dateAvailable, forKey: "dateAvailable")
//        objectToSave.setValue(isAvailable, forKey: "isAvailable")
//        objectToSave.setValue(photosTaken, forKey: "photosTaken")
//        objectToSave.setValue(photosRemaining, forKey: "photosRemaining")
//        objectToSave.setValue(lastSelected, forKey: "lastSelected")
//        
//        do { try managedContext.save() } catch {}
//        
//    }
    
    // Save Cover Image
    static func saveCoverImage (image: UIImage, albumName: String) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "CoverImage", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(image, forKey: "image")
        
        // find album object corresponding to albumName
        var searchResults = [NSManagedObject]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Album")
        let predicate = NSPredicate(format: "%K == %@", "title", albumName)
        fetchRequest.predicate = predicate
        do {
            if let fetchResult = try? managedContext.fetch(fetchRequest) {
                searchResults = fetchResult
            }
        }
        objectToSave.setValue(searchResults[0], forKey: "album")
        
        do { try managedContext.save() } catch {}
        
    }
    
    // Save Image
    static func saveImage (image: UIImage, imageCreatedDate: Date, owner: NSManagedObject, album: NSManagedObject ) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Image", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(image, forKey: "image")
        objectToSave.setValue(imageCreatedDate, forKey: "dateCreated")
        objectToSave.setValue(owner, forKey: "owner")
        objectToSave.setValue(album, forKey: "album")
        
        do { try managedContext.save() } catch {}
        
    }
    
    //Save User
    static func saveUser (username: String, profileImage: UIImage?) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(username, forKey: "name")
        objectToSave.setValue(profileImage, forKey: "profileImage")
        do { try managedContext.save() } catch {}
    }

    // Save Filter
    static func saveFilter (named: String, lastSelected: Date) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Filter", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(named, forKey: "name")
        objectToSave.setValue(lastSelected, forKey: "lastSelected")
        do { try managedContext.save() } catch {}
    }
    
    // Save Notification
    static func saveNotification (type: String, createdTime: Date, ownerObject: NSManagedObject) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Notification", in: managedContext)
        let objectToSave = NSManagedObject(entity: entity!, insertInto: managedContext)
        objectToSave.setValue(type, forKey: "type")
        objectToSave.setValue(createdTime, forKey: "created")
        objectToSave.setValue(ownerObject, forKey: "album")
        do { try managedContext.save() } catch {}
    }

    ///////////////////////////////////////////
    
    
    
    
    
    //////////////Updating/////////////////////
    
    static func updateAlbumInfo (album: NSManagedObject, date: Date?, photosRemaining: Int?, photosTaken: Int?) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        if date != nil {
            album.setValue(date, forKey: "lastSelected")
        }
        if photosRemaining != nil {
            album.setValue(photosRemaining, forKey: "photosRemaining")
        }
        if photosTaken != nil {
            album.setValue(photosTaken, forKey: "photosTaken")
        }
        
        appDelegate.saveContext()
    }
   
    static func updateFilterInfo (filter: NSManagedObject) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        filter.setValue(Date(), forKey: "lastSelected")
        appDelegate.saveContext()
    }
    
    
    
    ///////////////////////////////////////////
    
    
    
    
    
    
    
    ////////////////Fetching/////////////////////
    
    // Fetch Users
    static func fetchUsers(named: String) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        var results: [NSManagedObject] = []
        
        let predicate = NSPredicate(format:  "%K == %@", "name", named)
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResults = try? managedContext?.fetch(fetchRequest) {
                results = fetchResults!
            }
        }

        
        return results
    }
    
    
    // Fetch Albums
    static func fetchAlbums(isAvailable: Bool, source: String?, albumName: String?) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Album")
        
        var results: [NSManagedObject] = []
        
        let predicate1 = NSPredicate(format: "isAvailable = \(isAvailable)") // set past/future albums predicate
        var predicate2: NSPredicate?
        var compoundPredicate: NSPredicate?
        
        if albumName != nil {
            predicate2 = NSPredicate(format: "%K == %@", "title", albumName!)
        } else {
            predicate2 = nil
        }
        
        if predicate2 != nil {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2!])
            fetchRequest.predicate = compoundPredicate
        } else {
            fetchRequest.predicate = predicate1
        }
        
        // set sort rule according to album available date
        var sectionSortDescriptor = [NSSortDescriptor(key: "dateAvailable", ascending: !isAvailable)]
        
        // write-over sort rule according to 'last selected' date if fetch source is 'Choose Filter VC'
        if source == "ChooseAlbumVC" {
            sectionSortDescriptor = [NSSortDescriptor(key: "lastSelected", ascending: false)]
        }
        fetchRequest.sortDescriptors = sectionSortDescriptor
        
        do {
            if let fetchResults = try? managedContext?.fetch(fetchRequest) {
                results = fetchResults!
            }
        }
        return results
    }
    
    
    static func fetchActiveAlbums() -> [Album]? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ActiveAlbum")
        
        var searchResults: [NSManagedObject] = []
        
        // set sort rule according to album available date
        let sectionSortDescriptor = [NSSortDescriptor(key: "availableDate", ascending: true)]
        fetchRequest.sortDescriptors = sectionSortDescriptor
        
        do {
            if let fetchResults = try? managedContext?.fetch(fetchRequest) {
                searchResults = fetchResults!
            }
        }
        
        var activeAlbums: [Album] = []
        
        for album in searchResults {
            
            // get contributors
            var albumContributors: [Contributor] = []
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contributor")
            let sectionSortDescriptor = [NSSortDescriptor(key: "username", ascending: true)]
            fetchRequest.sortDescriptors = sectionSortDescriptor
            
            let albumID = album.value(forKey: "albumID") as! String
            let searchPredicate = NSPredicate(format: "%K == %@", "albumID", albumID)
            fetchRequest.predicate = searchPredicate
            
           // var searchResults: [NSManagedObject] = []
            do {
                if let fetchResults = try? managedContext?.fetch(fetchRequest) {
                    guard let results = fetchResults else { return nil }
                    for result in results {
                    let albumContributor = Contributor(
                        userID: result.value(forKey: "userID") as! String,
                        username: result.value(forKey: "username") as! String,
                        photosRemaining: result.value(forKey: "mediaRemaining") as! Int,
                        photosTaken: result.value(forKey: "mediaTaken") as! Int
                    )
                    albumContributors.append(albumContributor)
                }
            }
            }
            guard albumContributors.isEmpty != true else { print ("could not fetch contributors"); return nil}
            
            // create album objects from fetched local data
            let activeAlbum = Album(
                albumID: album.value(forKey: "albumID") as! String,
                ownerID:  album.value(forKey: "ownerID") as! String,
                title: album.value(forKey: "titleText") as! String,
                description: album.value(forKey: "descriptionText") as! String,
                createdDate: album.value(forKey: "createdDate") as! Date,
                availableDate: album.value(forKey: "availableDate") as! Date,
                contributors: albumContributors,
                coverURL: nil,
                coverImage: album.value(forKey: "coverImage") as! UIImage,
                isActive: album.value(forKey: "isActive") as! Bool
            )
            activeAlbums.append(activeAlbum)
        }
        
        return activeAlbums
    }
    
    
    
    
    
    
    // Fetch Cover Images
    static func fetchCoverImages (isAvailable: Bool?, album: NSManagedObject?) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoverImage")
        
        var results: [NSManagedObject] = []
        
        // define predicate according to whether cover image's corresponding album is available/not-available
        var predicate1: NSPredicate?
        if isAvailable == true {
            predicate1 = NSPredicate(format: "album.isAvailable = true")
        } else  if isAvailable == false {
            predicate1 = NSPredicate(format: "album.isAvailable = false")
        } else {
            predicate1 = nil
        }
        
        // define predicate to search for a single particular album if fetch parameter 'album' present
        var predicate2: NSPredicate?
        if album != nil {
            predicate2 = NSPredicate(format:  "%K == %@", "album", album!)
        } else {
            predicate2 = nil
        }
        
        // set predicates according to present fetch parameters
        if (predicate1 != nil) && (predicate2 != nil) {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1!, predicate2!])
            fetchRequest.predicate = compoundPredicate
        } else if predicate1 != nil {
            fetchRequest.predicate = predicate1
        } else {
            fetchRequest.predicate = predicate2
        }
        
        
        do {
            if let fetchResult = try? managedContext?.fetch(fetchRequest) {
                results = fetchResult!
            }
        }
        
        return results
    }
    
    
    
    // Fetch Images
    static func fetchImages (album : NSManagedObject?) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Image")
        
        var results: [NSManagedObject] = []
        
        // sort results according to 'date added'
        let sectionSortDescriptor = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        fetchRequest.sortDescriptors = sectionSortDescriptor
        
        // set predicate to search for a single particular album if fetch parameter present
        let predicate = NSPredicate(format: "%K == %@", "album", album!)
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResult = try? managedContext?.fetch(fetchRequest) {
                results = fetchResult!
            }
        }
        
        return results
        
    }
    
   
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
    
    
    // Fetch Notifications
    static func fetchNotifications () -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notification")
        
        var results: [NSManagedObject] = []
        
        let sectionSortDescriptor = [NSSortDescriptor(key: "created", ascending: false)]
        fetchRequest.sortDescriptors = sectionSortDescriptor
        
        do {
            if let fetchResult = try? managedContext?.fetch(fetchRequest) {
                results = fetchResult!
            }
        }
        
        return results
    }

    
    ///////////////////////////////////////////

    
    
    ////////////////Deleting/////////////////////
    
    static func deleteAlbum (album: NSManagedObject) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.managedObjectContext
        
        let albumToDelete = album
        let albumCoverFetchResult = CoreDataModel.fetchCoverImages(isAvailable: nil, album: album)
        let albumCoverToDelete = albumCoverFetchResult[0]
        
        managedContext.delete(albumToDelete)
        managedContext.delete(albumCoverToDelete)
        do { try managedContext.save() } catch {}
        print("album deleted")
    }
    
    
    
    
    
    
}
    













