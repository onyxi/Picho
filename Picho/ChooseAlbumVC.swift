//
//  ChooseAlbumVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 01/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

protocol UpdateAlbumButtonDelegate {
    func updateAlbumButton(album: Album)
        //(name: String, picCount: Int, coverImageName: UIImage)
}

import UIKit
import CoreData

class ChooseAlbumVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//   -------IB Outlets---------------------------
    @IBOutlet weak var tableView: UITableView!
    
//   -------Declare Variables---------------------------
    var updateAlbumButtonDelegate: UpdateAlbumButtonDelegate?
    
    // setup arrays to hold objects from Core Data
    var futureCoverImages: [NSManagedObject] = []
    var futureAlbums: [NSManagedObject] = []
    
    var activeAlbums: [Album] = []
    var currentlySelectedAlbum: Album?
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // set View Controller background appearance
        self.view.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear
        
        /// config tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // import album objects
       // self.futureAlbums = CoreDataModel.fetchAlbums(isAvailable: false, source: "ChooseAlbumVC", albumName: nil)
        
        // sort activeAlbums array
        tableView.reloadData() // refresh table with newly sorted objects
        
        // set initial selection of first cell in table
        let path = NSIndexPath(row: 0, section: 0)
        if activeAlbums.count > 0 {
            tableView.selectRow(at: path as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
        
        // set background colour of initially selected cell
        let cell = tableView.cellForRow(at: path as IndexPath)
        cell?.backgroundColor = UIColor(red: 244/255, green: 233/255, blue: 209/255, alpha: 1)
        
    }
    
    

//   -------Methods---------------------------

    /// unwind when back button pressed
    @IBAction func backButtonDidPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "unwindToCamVC", sender: self)
    }
    
    
    /// set up tableView and content
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return futureCoverImages.count
        //return futureAlbums.count
        return activeAlbums.count
    }
    
    // configure cells for album table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAlbumCell", for: indexPath) as! ChooseAlbumTableViewCell
    
        var imageForCell = UIImage(named: "rockiesCover") /// use default 'no cover' image here
        
        //let currentAlbum = futureAlbums[indexPath.row]
        let currentAlbum = activeAlbums[indexPath.row]
        var albumMediaCount = 0
        for contributor in currentAlbum.contributors {
            albumMediaCount += contributor.photosTaken
        }
        
//        if let albumCover = currentAlbum.value(forKey: "coverImage") as? NSManagedObject {
//            imageForCell = albumCover.value(forKey: "image") as? UIImage
//            cell.albumCoverTile.image = imageForCell
//        }

        if let albumCoverImage = currentAlbum.coverImage {
            cell.albumCoverTile.image = albumCoverImage
        }
        
//        if let titleForCell = currentAlbum.value(forKey: "title") as? String {
//            cell.albumTitleLabel.text = titleForCell
//        }
        
        cell.albumTitleLabel.text = currentAlbum.title
        
//        if let remainingPhotosForCell = currentAlbum.value(forKey: "photosRemaining") as? Int {
//            cell.remainingPhotosLabel.text = String(describing: remainingPhotosForCell)
//        }
        
        cell.remainingPhotosLabel.text = String(albumMediaCount)
        
        cell.backgroundColor = UIColor.clear
        
        
        
        return cell
           }
    
    // set height for cells in table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    /// update button text / images after item selection through protocol function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let selectedAlbum = futureAlbums[indexPath.row]
        let selectedAlbum = activeAlbums[indexPath.row]
        
        updateAlbumButtonDelegate?.updateAlbumButton(album: selectedAlbum)
        //(name: selectedAlbumTitle, picCount: selectedAlbumPicCount, coverImageName: selectedAlbumImage)
        
//        if let selectedAlbumTitle = selectedAlbum.value(forKey: "title") {
//            UserDefaults.standard.set(selectedAlbumTitle, forKey: "savedCurrentAlbum")
//        }
        UserDefaults.standard.set(selectedAlbum.albumID, forKey: "savedCurrentAlbumID")
        
        // add timestamp for lat time the album was selected
        // !!!!!!!!!!!!!!!!!!!
      //  CoreDataModel.updateAlbumInfo(album: selectedAlbum, date: Date(), photosRemaining: nil, photosTaken: nil)
        
        /*
        if let selectedAlbumTitle = selectedAlbum.value(forKey: "title") as? String {
            if let selectedAlbumPicCount = selectedAlbum.value(forKey: "photosRemaining") as? Int {
                let selectedAlbumCover = selectedAlbum.value(forKey: "coverImage") as? NSManagedObject
                if let selectedAlbumImage = selectedAlbumCover?.value(forKey: "image") as? UIImage {
                    delegate?.updateAlbumInfo(name: selectedAlbumTitle, picCount: selectedAlbumPicCount, coverImageName: selectedAlbumImage)
                    UserDefaults.standard.set(selectedAlbumTitle, forKey: "savedCurrentAlbum")
                    /// update last-selected time
                    CoreDataModel.updateAlbumInfo(album: selectedAlbum)
                }
            }
        }
        */

        /// override highlighted cell color on selection
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor(red: 244/255, green: 233/255, blue: 209/255, alpha: 1)
        
        
    }
    
    /// remove highlighted cell color on de-selection
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
//   -------General---------------------------
    
    
}
