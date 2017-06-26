//
//  ChooseFilterVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 01/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//


protocol UpdateFilterDelegate {
    func updateFilterInfo (filterName: String)
}


import UIKit
import CoreData

class ChooseFilterVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

//   -------IB Outlets---------------------------
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
//   -------Declare Variables---------------------------
    var delegate: UpdateFilterDelegate?
    
    var filterIndex = 0
    
    // set up variables to hold managed objects from core data
    var currentAlbumImage: UIImage?
    var filters: [NSManagedObject] = []
    
    var currentlySelectedAlbum: Album?
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor.clear
        
        // get current album object from Core Data using name from NSUserDefaults
//        let savedCurrentAlbum = UserDefaults.standard.string(forKey: "savedCurrentAlbum")
//        var currentAlbum: NSManagedObject?
//        let availableAlbums = CoreDataModel.fetchAlbums(isAvailable: false, source: nil, albumName: nil)
//        for album in availableAlbums {
//            if album.value(forKey: "title") as? String == savedCurrentAlbum {
//                currentAlbum = album
//            }
//        }
        
        // filters from Core Data - sorted by last used date
  //      self.filters = CoreDataModel.fetchFilters()
        
        // set View Controller's main image variable to album's Cover Image
        //let currentAlbumCover = currentAlbum?.value(forKey: "coverImage") as? NSManagedObject
        //currentAlbumImage = currentAlbumCover?.value(forKey: "image") as? UIImage
        if currentlySelectedAlbum != nil {
            currentAlbumImage = currentlySelectedAlbum?.coverImage
            // set screen image to main image variable
            mainImage.image = currentAlbumImage
        }
        
    
    }
    
    
    // select first row in table as initial selection
    override func viewWillAppear(_ animated: Bool) {
        self.filters = FBService.fetchFilters()
        collectionView.reloadData()
        
        let path = NSIndexPath(row: 0, section: 0) as IndexPath
        if filters.count > 0 {
            collectionView.selectItem(at: path as IndexPath, animated: false, scrollPosition: [])
        }
    }
    
    
//   -------Methods---------------------------
    // set number of items in filter collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    // set size of items in filter colletion view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 81, height: 94)
    }
    
    // configure cells in filter collection view
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseFilterCell", for: indexPath) as! ChooseFilterCollectionViewCell
        
        // set item image
        cell.filterImage.image = currentAlbumImage
        
        // set background colour
        if self.filterIndex == indexPath.row {
            cell.filterBackground.backgroundColor = UIColor(red: 244/255, green: 233/255, blue: 209/255, alpha: 1)
        } else {
            cell.filterBackground.backgroundColor = UIColor.clear
        }
        
        // set item titles
        let filterName = filters[indexPath.row].value(forKey: "name") as? String
        cell.filterLabel.text = filterName
        
    
        return cell
        
    }

    /// update filter button text on previous view controller when selection made
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // update 'last selected' date
        FBService.updateFilterInfo (filter: filters[indexPath.row])
        
        // set background colour
        self.filterIndex = indexPath.row // set global index for selected filter
        let cell = collectionView.cellForItem(at: indexPath)! as! ChooseFilterCollectionViewCell
        if self.filterIndex == indexPath.row {
            cell.filterBackground.backgroundColor = UIColor(red: 244/255, green: 233/255, blue: 209/255, alpha: 1)
        } else {
            cell.filterBackground.backgroundColor = UIColor.clear
        }
        
        // change filter button text
        if let filterName = filters[indexPath.row].value(forKey: "name") as? String {
            delegate?.updateFilterInfo(filterName: filterName)
            UserDefaults.standard.set(filterName, forKey: "savedCurrentFilter")
        }
        
        // change background color of selected item
        let selectedCell = collectionView.cellForItem(at: indexPath)! as! ChooseFilterCollectionViewCell
        selectedCell.filterBackground.backgroundColor = UIColor(red: 244/255, green: 233/255, blue: 209/255, alpha: 1)
    }
    
    // reset colour when item de-selected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? ChooseFilterCollectionViewCell {
            selectedCell.filterBackground.backgroundColor = UIColor.clear
        }
    }
    
//   -------General---------------------------
    

}
