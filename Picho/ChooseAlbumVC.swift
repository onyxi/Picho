//
//  ChooseAlbumVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 01/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

protocol UpdateAlbumButtonDelegate {
    func updateAlbumButton()
        //(name: String, picCount: Int, coverImageName: UIImage)
}

import UIKit
import CoreData

class ChooseAlbumVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//   -------IB Outlets---------------------------
    @IBOutlet weak var tableView: UITableView!
    
//   -------Declare Variables---------------------------
    var updateAlbumButtonDelegate: UpdateAlbumButtonDelegate?
    
    let dataService = DataService()
    
    let constants = Constants()
    
    // declare properties to hold Album data from disk
    var activeAlbums: [Album] = []
    var selectedAlbum: Album?
    
    
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

        // get active albums from Core Data
        if let localAlbums = dataService.fetchLocalActiveAlbums(albumID: nil) {
            activeAlbums = localAlbums
        }
        
        let selectedAlbumID = UserDefaults.standard.value(forKey: self.constants.CURRENTACTIVEALBUMID) as? String
        for album in activeAlbums {
            if album.albumID == selectedAlbumID {
                selectedAlbum = album
            }
        }
        
        tableView.reloadData() // refresh table with fetched objects
        
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
        return activeAlbums.count
    }
    
    // configure cells for album table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAlbumCell", for: indexPath) as! ChooseAlbumTableViewCell
        
        let currentAlbum = activeAlbums[indexPath.row]
        
        if let albumCoverImage = currentAlbum.coverImage {
            cell.albumCoverTile.image = albumCoverImage
        }
        
        cell.albumTitleLabel.text = currentAlbum.title
        
        cell.remainingPhotosLabel.text = String(describing: currentAlbum.userMediaRemaining())
    
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
        
        dataService.setAlbumLastUsedTime(album: selectedAlbum)
        
        UserDefaults.standard.set(selectedAlbum.albumID, forKey: self.constants.CURRENTACTIVEALBUMID)
        updateAlbumButtonDelegate?.updateAlbumButton()
       
      
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
