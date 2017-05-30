//
//  NotesVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 08/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

protocol GoToPicsVCDelegate {
    func goToPicsVC()
}

class NotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, GoToPicsVCDelegate, FetchNotifsDelegate, FetchSingleAlbumDelegate {

//   -------IB Outlets---------------------------
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    
//   -------Declare Variables---------------------------

    // set up variables to hold Core Data objects
   // var notifications: [NSManagedObject] = []

    var notifs: [Notif] = []
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// set NavigationBar title as logo
        let titleLogo = UIImageView()
        titleLogo.image = UIImage(named: "logo")
        titleLogo.frame.size.width = 100
        titleLogo.frame.size.height = 30
        let logoOrigin = (self.view.bounds.width / 2) - 50
        titleLogo.frame.origin = CGPoint(x: logoOrigin, y: 25)
        self.navigationItem.titleView = titleLogo
        self.navBar.addSubview(titleLogo)
        
        // import Notifications from Core Data
        //self.notifications = CoreDataModel.fetchNotifications()
        
        let fbService = FBService()
        fbService.fetchNotifsDelegate = self
        fbService.fetchNotifs()
        
        /// config tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    
//   -------Methods---------------------------
    
    /// show ProfileVC popover view controller
    @IBAction func settingButtonPressed(_ sender: AnyObject) {
        
        /// create instance of ProfileVC
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        
        /// set up presentation controller
        profileVC.modalPresentationStyle = .popover
        profileVC.preferredContentSize = CGSize(width: self.view.bounds.width, height: 385)
        profileVC.delegate = self
        if let popoverController = profileVC.popoverPresentationController {
            popoverController.barButtonItem = settingsButton
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
            popoverController.sourceRect = CGRect(x:20, y:0, width: 1, height: 2)
        }
        
        /// display ProfileVC
        present(profileVC, animated: true, completion: nil)
        
    }
    
    
    
    func goToPicsVC() {
        // check if Firebase user currently authenticated -- // is this actually necessary??
        guard FIRAuth.auth()?.currentUser != nil else {
            guard let tabBarController = self.tabBarController else { return }
            tabBarController.selectedIndex = 0
         //   performSegue(withIdentifier: "SignOutToLogin", sender: nil)
            return
        }
    }
    
    /// force popover style of View Controller presentation
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    
    /// set up table and contents
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifs.count + 1
    }
    
    // configure cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 { // config initial cell when opening app for first time
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesFirstCell", for: indexPath) as! NotificationFirstTableViewCell
            return cell
            
        } else { // config subsequent cells
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesType1Cell", for: indexPath) as! NotificationType1TableViewCell
            
            // get notification's asociated album object
            // -- let notificationsAlbum = notifications[indexPath.row - 1].value(forKey: "album") as? NSManagedObject
            let notification = notifs[indexPath.row - 1]
            
            var notifText: NSAttributedString?
            var notifImage: UIImage?
            
            switch notification.notifType {
            case "albumReady" :
                let albumName = notification.title!
                var boldLength = albumName.characters.count
                
                func notificationText()->NSAttributedString{
                    let string = "Your album \(albumName) is now available!" as NSString
                    let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11.0)])
                    let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 11.0)]
                    attributedString.addAttributes(boldFontAttribute, range: NSRange(location:11,length: boldLength)) // Part of string to be bold
                    return attributedString
                }
                cell.notificationLabel.attributedText = notificationText()
                
                let notifImage = notification.image
                cell.notificationImage.image = notifImage
                
                break
            default : break
            }
            
            
            
            
            return cell
            
            // get title of notification's associated album
            // -- let albumName = notificationsAlbum?.value(forKey: "title") as! String
            
            // get length of string to embolden
            //var boldLength = albumName.characters.count
            
            /// set notification text with Bold album title
//            func attributedText()->NSAttributedString{
//                let string = "Your album \(albumName) is now available!" as NSString
//                let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 11.0)])
//                let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 11.0)]
//                attributedString.addAttributes(boldFontAttribute, range: NSRange(location:11,length: boldLength)) // Part of string to be bold
//                return attributedString
//            }
//            cell.notificationLabel.attributedText = attributedText()
//            
//            // set notification associated album's image
//            let albumCoverImage = notificationsAlbum?.value(forKey: "coverImage") as? NSManagedObject
//            let cellImage = albumCoverImage?.value(forKey: "image") as? UIImage
//            
//            cell.notificationImage.image = cellImage
//            
//            return cell
        }
        
    }
    
    // set table cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return 60
        } else {
            return 50
        }
    }
    
    /// select notification and show corresponding album
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        
        // make cell blink on click
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        
        // display album from notification
//        let selectedNotification = notifications[indexPath.row - 1]
//        let selectedNotificationAlbum = selectedNotification.value(forKey: "album") as? NSManagedObject
        let selectedNotif = notifs[indexPath.row - 1]
        let selectedNotificationAlbumID = selectedNotif.albumID
        let fbService = FBService()
        fbService.fetchSingleAlbumDelegate = self
        fbService.fetchSingleAlbumData(ownerID: selectedNotif.objectOwnerID!, albumID: selectedNotif.albumID!)
       
    }
    
    
    func didFetchSingleAlbum(album: Album) {
        print("did fetch single album")
         performSegue(withIdentifier: "notesToAlbumSegue", sender: album)
    }
    
    // prepare recieving View Controller to dsplay album relating to selected item
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "SignOutToLogin" {
        let destinationNavVC = segue.destination as! UINavigationController
            if let destinationVC = destinationNavVC.topViewController as? AlbumPicsGalleryVC? {
//                if let album = sender as? NSManagedObject {
//                  //  destinationVC?.selectedAlbum = album
//                }
                if let selectedAlbum = sender as? Album {
                   
                    destinationVC?.selectedAlbum = selectedAlbum
                }
            }
        }
    }
    
    
    func didFetchNotifs(fetchedNotifs: [Notif]) {
        notifs = fetchedNotifs
        tableView.reloadData()
//        var index = 0
//        for notification in notifs {
//            index += 1
//            print ("Notif \(index):")
//            print ("User ID: \(notification.userID)")
//            print ("Date: \(notification.createdDate)")
//            print ("Notification type: \(notification.notifType)")
//            print ("Object type: \(notification.objectType)")
//            print ("Object owner ID: \(notification.objectOwnerID)")
//            print ("Object owner username: \(notification.objectOwnerUsername)")
//            print ("Album ID: \(notification.albumID)")
//            print ("Media ID: \(notification.mediaID)")
//            print ("Album title: \(notification.title)")
//            print ("Image: \(notification.image)")
//            
//        }
    }
    
    
//   -------General---------------------------
    
    /// set light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// hook for unwind segue
    @IBAction func unwindToNotesVC(segue: UIStoryboardSegue) {}
    


}
