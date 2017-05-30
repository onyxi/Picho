//
//  AppDelegate.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 28/08/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import CoreData

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /// Firebase config
        
  
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
            
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]

        
        
        
        FIRApp.configure()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
       
        
        // End Firebase config
  
        
//// ------------------------------
        // UPLOAD DEVELOPMENT DATA
        
        // [START uploading data]
        
        
        
        // [END uploading data]
        
        
        //// ------------------------------
        
         UserDefaults.standard.set("CE23DE59-ADB0-4A61-B7E1-BC2DE25DF9DC", forKey: "savedCurrentAlbumID")
        
        
        //// check if logged into Firebase
        
//        if let userLoggedInToFirebase = UserDefaults.standard.value(forKey: "userLoggedInToFirebase") as? Bool {
//            if let dataHasBeenLoaded = UserDefaults.standard.value(forKey: "dataHasBeenLoaded") as? Bool {
//                if dataHasBeenLoaded == false {
//                    DevData.instance.uploadDataToFirebase()
//                }
//            }
//        }
        
        // if a user ID is currently stored, load that user's data from FB to memory
       // if let myUserID = UserDefaults.standard.value(forKey: "myUserID") as? String {
           // print (myUserID)
           // FBService().loadUserDataFromFB(userID: myUserID)
        //}

        
        func loadCurrentUser() {
            
            guard FIRAuth.auth()?.currentUser != nil else { print ("user not authenticated")
                return }
            guard (UserDefaults.standard.value(forKey: "isLoaded") as? Bool) != nil else { print ("user details not saved locally")
                return }
            guard let myUserID = UserDefaults.standard.value(forKey: "myUserID") as? String else { print ("no user ID")
                return }
            guard let myUsername = UserDefaults.standard.value(forKey: "myUsername") as? String else { print ("no username")
                return }
            guard let myPassword = UserDefaults.standard.value(forKey: "myPassword") as? String else { print ("no password")
                return }
            guard let myEmail = UserDefaults.standard.value(forKey: "myEmail") as? String else { print ("no email")
                return }
            guard let myProfilePicURL = UserDefaults.standard.value(forKey: "myProfilePicURL") as? String else { print ("no profile pic url")
                return }
            
            LoggedInUser.myUserID = myUserID
            LoggedInUser.myUsername = myUsername
            LoggedInUser.myPassword = myPassword
            LoggedInUser.myEmail = myEmail
            LoggedInUser.myProfilePicURL = myProfilePicURL
            LoggedInUser.isLoaded = true
            
            print ("User loaded")
        }
        loadCurrentUser()
        
        // [START UPLOADING TEST DATA]
    //    DevData.instance.saveDevData()
        // [END UPLOADING TEST DATA]
        
        
//        if let myUserID = UserDefaults.standard.value(forKey: "myUserID") as? String {
//            DataService.instance.getAndStoreLoggedInUserInfo(userID: myUserID)
//        }

//        UserDefaults.standard.set(nil, forKey: "savedCurrentAlbum")
//        UserDefaults.standard.set(nil, forKey: "savedCurrentFilter")
//        UserDefaults.standard.set(nil, forKey: "userLoggedInToFirebase")
//        UserDefaults.standard.set(nil, forKey: "dataHasBeenLoaded")
//        UserDefaults.standard.set(nil, forKey: "currentUserID")  /// old
//        UserDefaults.standard.set(nil, forKey: "myUserID")
//        UserDefaults.standard.set(nil, forKey: "myUsername")
//        UserDefaults.standard.set(nil, forKey: "myPassword")
//        UserDefaults.standard.set(nil, forKey: "myEmail")
//        UserDefaults.standard.set(nil, forKey: "myProfilePicURL")
        
        // assign initial User Name
       // UserDefaults.standard.set("Pete Holdsworth", forKey: "username")
        
        // load logged in user data 
//        LoggedInUser.userID = UserDefaults.standard.value(forKey: "loggedInUserID") as! String
//        LoggedInUser.email = "pete@picho.com"
//        LoggedInUser.profilePicURL = "https://firebasestorage.googleapis.com/v0/b/picho-51f78.appspot.com/o/profileMedia%2FprofilePicture.jpg?alt=media&token=ce2bb9e6-155a-436c-aa1d-28089f914881"
//        LoggedInUser.username = "Pete Holdsworth"
        
        /// assign initial filters/albums
        let savedCurrentAlbum = UserDefaults.standard.value(forKey: "savedCurrentAlbum")
        let savedCurrentFilter = UserDefaults.standard.value(forKey: "savedCurrentFilter")
        
        if savedCurrentAlbum == nil {
            UserDefaults.standard.set("Travels", forKey: "savedCurrentAlbum") //setObject
        }
        if savedCurrentFilter == nil {
            UserDefaults.standard.set("Warm", forKey: "savedCurrentFilter") //setObject
        }
        
        
        
///////// test Firebase data service ///////////
   //     UserDefaults.standard.set("sKmh2PdFR9Yy0oBTKpD6CZwqnRo2", forKey: "currentUserID")
        
        // [START upload profile image from local]
        /*
        if let localFile = UIImage(named: "PHProfileImage") {
            DataService.instance.uploadImageFromLocal(type: "profileMedia", image: localFile)
        }
        */
        // [END upload profile image from local]
        
        
        
        

        
        
        
        
        
        
        
////////////////////////////////////////////////
        
      //  UserDefaults.standard.set(false, forKey: "dataHasBeenLoaded")
        var dataHasBeenLoaded2 = true
//REMOVE            //UserDefaults.standard.value(forKey: "dataHasBeenLoaded") as? Bool
        
        
        
        if dataHasBeenLoaded2 == nil {
            UserDefaults.standard.set(true, forKey: "dataHasBeenLoaded")
            print ("Data Loaded")
            
        var dateFmt = DateFormatter()
        dateFmt.timeZone = NSTimeZone.default
        dateFmt.dateFormat =  "dd-MM-yyyy"
        let now = Date()
        
            
            /// create Users
            let PHProfileImage = UIImage(named: "PHProfileImage")
            CoreDataModel.saveUser(username: "Pete Holdsworth", profileImage: PHProfileImage)
            
            /// create Albums Method
            func createAlbumRecord(title: String, description: String, created: String, available: String, isAvailable: Bool, photosTaken: Int, photosRemaining: Int, lastSelected: Date) {
                let albumTitle = title
                let albumDescription = description
                let albumCreatedDate = dateFmt.date(from: created)
                let albumAvailableDate = dateFmt.date(from: available)
                let albumIsAvailable = isAvailable
                let albumPhotosTaken = photosTaken
                let albumPhotosRemaining = photosRemaining
                let albumLastSelected = lastSelected
              //  CoreDataModel.saveAlbum(title: albumTitle, albumDescription: albumDescription, owner: "Pete Holdsworth", dateCreated: albumCreatedDate!, dateAvailable: albumAvailableDate!, isAvailable: albumIsAvailable, photosTaken: albumPhotosTaken, photosRemaining: albumPhotosRemaining, lastSelected: albumLastSelected)
            }
            
            
            
            //// create Albums /////
            //// past
            
            createAlbumRecord(title: "Christmas", description: "A week of festive fun with family and friends", created: "21-12-2016", available: "01-01-2017", isAvailable: true, photosTaken: 6, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Holiday in Vegas", description: "Vegas Baby! Happy 4th of July!", created: "03-07-2016", available: "08-08-2016", isAvailable: true, photosTaken: 11, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Summer Fun", description: "Time to relax...", created: "08-07-2016", available: "01-08-2016", isAvailable: true, photosTaken: 19, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Fun with Friends", description: "Good times with good people...", created: "03-01-2016", available: "25-06-2016", isAvailable: true, photosTaken: 8, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "The Rockies", description: "Mountain life at its best", created: "02-03-2016", available: "22-03-2016", isAvailable: true, photosTaken: 23, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Food Festival", description: "A day of culinary delights!", created: "04-03-2016", available: "04-03-2016", isAvailable: true, photosTaken: 15, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Honeymoon", description: "Magical times with my better half", created: "21-02-2016", available: "27-02-2016", isAvailable: true, photosTaken: 15, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Weekend Break", description: "How much fun can you have in 48 hours?", created: "01-02-2016", available: "04-02-2016", isAvailable: true, photosTaken: 20, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Country Life", description: "Getting back to roots and a breath of fresh air", created: "01-09-16", available: "10-09-16", isAvailable: true, photosTaken: 5, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Olympic Games", description: "Celebrating human achievement at Rio 2016 Olympic Games", created: "01-08-16", available: "30-08-16", isAvailable: true, photosTaken: 9, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "India", description: "Finding ourselves - in the sub-continent", created: "06-07-16", available: "08-08-16", isAvailable: true, photosTaken: 8, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Family Hols", description: "Lovely week catching up with the fam", created: "01-06-16", available: "30-06-16", isAvailable: true, photosTaken: 8, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "21 Birthday!", description: "You only live once - this is going to be epic!", created: "04-05-2016", available: "15-06-16", isAvailable: true, photosTaken: 5, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Safari", description: "A short walk in the Serengeti", created: "10-03-16", available: "20-03-16", isAvailable: true, photosTaken: 6, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "NYE", description: "Happy New Year 2016!", created: "30-12-15", available: "01-01-16", isAvailable: true, photosTaken: 4, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "New Zealand", description: "The end of the earth", created: "05-10-15", available: "08-12-15", isAvailable: true, photosTaken: 5, photosRemaining: 0, lastSelected: now)
            createAlbumRecord(title: "Indonesia", description: "4 months in paradise", created: "20-06-15", available: "03-10-15", isAvailable: true, photosTaken: 6, photosRemaining: 0, lastSelected: now)
            
            
            
            //// future
            createAlbumRecord(title: "Jim's Wedding", description: "A beautiful day", created: "08-10-2016", available: "10-10-2016", isAvailable: false, photosTaken: 7, photosRemaining: 14, lastSelected: now)
            createAlbumRecord(title: "Music Festival", description: "This is going to be awesome!", created: "28-10-2016", available: "29-10-2016", isAvailable: false, photosTaken: 7, photosRemaining: 19, lastSelected: now)
            createAlbumRecord(title: "Travels", description: "The trip of a lifetime", created: "03-11-2016", available: "10-11-2016", isAvailable: false, photosTaken: 6, photosRemaining: 58, lastSelected: now)
            createAlbumRecord(title: "The Boys", description: "They grow up so fast!", created: "22-11-2016", available: "02-12-2020", isAvailable: false, photosTaken: 3, photosRemaining: 46, lastSelected: now)
            createAlbumRecord(title: "Martha", description: "Our little angel", created: "04-12-2016", available: "04-03-2022", isAvailable: false, photosTaken: 4, photosRemaining: 62, lastSelected: now)
            
            
            //// fetch album objects for association with images
            let pastAlbums = CoreDataModel.fetchAlbums(isAvailable: true, source: nil, albumName: nil)
            let futureAlbums = CoreDataModel.fetchAlbums(isAvailable: false, source: nil, albumName: nil)
            ////////////////////////////
            
            
            /// create album covers method
            func createCoverImageRecord(title: String, albumRef: Int, isPast: Bool) {
                let uiImage = UIImage(named: title)!
                var albumName: String!
                if isPast == true {
                    albumName = pastAlbums[albumRef].value(forKey: "title") as! String
                } else {
                    albumName = futureAlbums[albumRef].value(forKey: "title") as! String
                }
                CoreDataModel.saveCoverImage(image: uiImage, albumName: albumName)
                FireSD.uploadPhotoFromMemory(albumName: albumName, photoName: "cover", photo: uiImage)
            }
            
            // create album covers
            //// past
            createCoverImageRecord(title: "christmasCover", albumRef: 0, isPast: true)
            createCoverImageRecord(title: "vegasCover", albumRef: 1, isPast: true)
            createCoverImageRecord(title: "summerCover", albumRef: 2, isPast: true)
            createCoverImageRecord(title: "friendsCover", albumRef: 3, isPast: true)
            createCoverImageRecord(title: "rockiesCover", albumRef: 4, isPast: true)
            createCoverImageRecord(title: "foodCover", albumRef: 5, isPast: true)
            createCoverImageRecord(title: "honeymoonCover", albumRef: 6, isPast: true)
            createCoverImageRecord(title: "weekendCover", albumRef: 7, isPast: true)
            createCoverImageRecord(title: "countryCover", albumRef: 8, isPast: true)
            createCoverImageRecord(title: "olympicsCover", albumRef: 9, isPast: true)
            createCoverImageRecord(title: "indiaCover", albumRef: 10, isPast: true)
            createCoverImageRecord(title: "familyCover", albumRef: 11, isPast: true)
            createCoverImageRecord(title: "birthdayCover", albumRef: 12, isPast: true)
            createCoverImageRecord(title: "safariCover", albumRef: 13, isPast: true)
            createCoverImageRecord(title: "NYCover", albumRef: 14, isPast: true)
            createCoverImageRecord(title: "NZCover", albumRef: 15, isPast: true)
            createCoverImageRecord(title: "indoCover", albumRef: 16, isPast: true)
            
            
            /// future
            createCoverImageRecord(title: "weddingCover", albumRef: 0, isPast: false)
            createCoverImageRecord(title: "festivalCover", albumRef: 1, isPast: false)
            createCoverImageRecord(title: "travelsCover", albumRef: 2, isPast: false)
            createCoverImageRecord(title: "theBoysCover", albumRef: 3, isPast: false)
            createCoverImageRecord(title: "marthaCover", albumRef: 4, isPast: false)
            
            
            /// create images method
            func createImageRecord (title: String, created: String, albumRef: Int, isPast: Bool, picRef: Int) {
                let uiImage = UIImage(named: title)!
                let imageCreatedDate = dateFmt.date(from: created)
                let testUser = CoreDataModel.fetchUsers(named: "Pete Holdsworth")
                
                var albumName: String!
                let photoNumberString = String(describing: picRef)
                let photoName = "photo: \(photoNumberString)"
                
                if isPast == true {
                    let album = pastAlbums[albumRef]
                    albumName = album.value(forKey: "title") as! String
                    CoreDataModel.saveImage(image: uiImage, imageCreatedDate: imageCreatedDate!, owner: testUser[0],album: album)
                } else {
                    let album = futureAlbums[albumRef]
                    albumName = album.value(forKey: "title") as! String
                    CoreDataModel.saveImage(image: uiImage, imageCreatedDate: imageCreatedDate!, owner: testUser[0], album: album)
                }
                FireSD.uploadPhotoFromMemory(albumName: albumName, photoName: photoName, photo: uiImage)
            }

            
            
            // create images
            /// past
            var christmasIndex = 1
            while christmasIndex <= 6 {
                let title = "christmas" + String(christmasIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 0, isPast: true, picRef: christmasIndex)
                christmasIndex += 1
            }
            var vegasIndex = 1
            while vegasIndex <= 11 {
                let title = "vegas" + String(vegasIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 1, isPast: true, picRef: vegasIndex)
                vegasIndex += 1
            }
            var summerIndex = 1
            while summerIndex <= 19 {
                let title = "summer" + String(summerIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 2, isPast: true, picRef: summerIndex)
                summerIndex += 1
            }
            var friendsIndex = 1
            while friendsIndex <= 8 {
                let title = "friends" + String(friendsIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 3, isPast: true, picRef: friendsIndex)
                friendsIndex += 1
            }
            var rockiesIndex = 1
            while rockiesIndex <= 23 {
                let title = "rockies" + String(rockiesIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 4, isPast: true, picRef: rockiesIndex)
                rockiesIndex += 1
            }
            var foodIndex = 1
            while foodIndex <= 15 {
                let title = "food" + String(foodIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 5, isPast: true, picRef: foodIndex)
                foodIndex += 1
            }
            var honeymoonIndex = 1
            while honeymoonIndex <= 15 {
                let title = "honeymoon" + String(honeymoonIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 6, isPast: true, picRef: honeymoonIndex)
                honeymoonIndex += 1
            }
            var weekendIndex = 1
            while weekendIndex <= 20 {
                let title = "weekend" + String(weekendIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 7, isPast: true, picRef: weekendIndex)
                weekendIndex += 1
            }
            var countryIndex = 1
            while countryIndex <= 5 {
                let title = "country" + String(countryIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 8, isPast: true, picRef: countryIndex)
                countryIndex += 1
            }
            var olympicsIndex = 1
            while olympicsIndex <= 8 {
                let title = "olympics" + String(olympicsIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 9, isPast: true, picRef: olympicsIndex)
                olympicsIndex += 1
            }
            
            var indiaIndex = 1
            while indiaIndex <= 8 {
                let title = "india" + String(indiaIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 10, isPast: true, picRef: indiaIndex)
                indiaIndex += 1
            }
            var familyIndex = 1
            while familyIndex <= 8 {
                let title = "family" + String(familyIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 11, isPast: true, picRef: familyIndex)
                familyIndex += 1
            }
            var birthdayIndex = 1
            while birthdayIndex <= 5 {
                let title = "birthday" + String(birthdayIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 12, isPast: true, picRef: birthdayIndex)
                birthdayIndex += 1
            }
            var safariIndex = 1
            while safariIndex <= 5 {
                let title = "safari" + String(safariIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 13, isPast: true, picRef: safariIndex)
                safariIndex += 1
            }
            var NYIndex = 1
            while NYIndex <= 4 {
                let title = "NY" + String(NYIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 14, isPast: true, picRef: NYIndex)
                NYIndex += 1
            }
            var NZIndex = 1
            while NZIndex <= 5 {
                let title = "NZ" + String(NZIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 15, isPast: true, picRef: NZIndex)
                NZIndex += 1
            }
            var indoIndex = 1
            while indoIndex <= 6 {
                let title = "indo" + String(indoIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 16, isPast: true, picRef: indoIndex)
                indoIndex += 1
            }
            
            
            //////future
            
            var weddingIndex = 1
            while weddingIndex <= 7 {
                let title = "wedding" + String(weddingIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 0, isPast: false, picRef: weddingIndex)
                weddingIndex += 1
            }
            var festivalIndex = 1
            while festivalIndex <= 7 {
                let title = "festival" + String(festivalIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 1, isPast: false, picRef: festivalIndex)
                festivalIndex += 1
            }
            var travelsIndex = 1
            while travelsIndex <= 6 {
                let title = "travels" + String(travelsIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 2, isPast: false, picRef: travelsIndex)
                travelsIndex += 1
            }
            var theBoysIndex = 1
            while theBoysIndex <= 3 {
                let title = "theBoys" + String(theBoysIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 3, isPast: false, picRef: theBoysIndex)
                theBoysIndex += 1
            }
            var marthaIndex = 1
            while marthaIndex <= 4 {
                let title = "martha" + String(marthaIndex)
                createImageRecord(title: title, created: "01-06-16", albumRef: 4, isPast: false, picRef: marthaIndex)
                marthaIndex += 1
            }
            
            
        
        

        /// create Filters
        CoreDataModel.saveFilter(named: "Warm", lastSelected: now)
        CoreDataModel.saveFilter(named: "Cool", lastSelected: now)
        CoreDataModel.saveFilter(named: "Nostalgia", lastSelected: now)
        CoreDataModel.saveFilter(named: "Classic", lastSelected: now)
        CoreDataModel.saveFilter(named: "Black & White", lastSelected: now)
        
    
        
        // create Notifications method
        func createNotification (type: String, ownerObjectIndex: Int) {
            let availableAlbums = CoreDataModel.fetchAlbums(isAvailable: true, source: nil, albumName: nil)
            let ownerObject = availableAlbums[ownerObjectIndex]
            CoreDataModel.saveNotification(type: type, createdTime: now, ownerObject: ownerObject)
        }
            
        // create Notifications
        createNotification(type: "albumReady", ownerObjectIndex: 0)
        createNotification(type: "albumReady", ownerObjectIndex: 1)
        createNotification(type: "albumReady", ownerObjectIndex: 2)
        createNotification(type: "albumReady", ownerObjectIndex: 3)
        createNotification(type: "albumReady", ownerObjectIndex: 4)
        createNotification(type: "albumReady", ownerObjectIndex: 5)
        createNotification(type: "albumReady", ownerObjectIndex: 6)
        createNotification(type: "albumReady", ownerObjectIndex: 7)
        createNotification(type: "albumReady", ownerObjectIndex: 8)
        createNotification(type: "albumReady", ownerObjectIndex: 9)
        createNotification(type: "albumReady", ownerObjectIndex: 10)
        createNotification(type: "albumReady", ownerObjectIndex: 11)
        createNotification(type: "albumReady", ownerObjectIndex: 12)
        createNotification(type: "albumReady", ownerObjectIndex: 13)
        createNotification(type: "albumReady", ownerObjectIndex: 14)
        createNotification(type: "albumReady", ownerObjectIndex: 15)
        createNotification(type: "albumReady", ownerObjectIndex: 16)
            
        ///////// end loading production data
       
        }
        
        return true
    }

    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "co.uk.onyxinteractive.AlbmsApp" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "AlbmsApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the applicationo generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    ///// Firebase

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    
    
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
         FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }

    
    
    

}







// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}
// [END ios_10_data_message_handling]




