//
//  ChooseFilterVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 01/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//


protocol UpdateFilterButtonDelegate {
    func updateFilterButton ()
}


import UIKit
import CoreData

class ChooseFilterVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

//   -------IB Outlets---------------------------
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
//   -------Declare Variables---------------------------
    var updateFilterButtonDelegate: UpdateFilterButtonDelegate?
    
    let constants = Constants()
    
    let dataService = DataService()
    
    var filterIndex = 0
    
    // set up variables to hold managed objects from core data
    var filters : [Filter] = []
    var selectedFilter: Filter?
    var currentAlbum: Album?
    
    
//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor.clear
    
    }
    
    
    // select first row in table as initial selection
    override func viewWillAppear(_ animated: Bool) {
        
        filters = dataService.fetchFilters(filterID: nil)
        
        let filters_array = dataService.fetchFilters(filterID: UserDefaults.standard.value(forKey: self.constants.CURRENTFILTERID) as? String)
        if filters_array.count > 0 {
            selectedFilter = filters_array[0]
        }
        
        
        if let array_albums = dataService.fetchLocalActiveAlbums(albumID: UserDefaults.standard.value(forKey: self.constants.CURRENTACTIVEALBUMID) as? String) {
            if array_albums.count > 0 {
                currentAlbum = array_albums[0]
                mainImage.image = currentAlbum?.coverImage
            }
        }
        
    
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
        cell.filterImage.image = currentAlbum?.coverImage
        
        // set background colour
        if self.filterIndex == indexPath.row {
            cell.filterBackground.backgroundColor = UIColor(red: 244/255, green: 233/255, blue: 209/255, alpha: 1)
        } else {
            cell.filterBackground.backgroundColor = UIColor.clear
        }
        
        // set item titles
        let filterName = filters[indexPath.row].name
        cell.filterLabel.text = filterName
        
    
        return cell
        
    }

    /// update filter button text on previous view controller when selection made
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // update 'last selected' date
        let selectedFilter = filters[indexPath.row]        
        dataService.setFilterLastUsedTime(filter: selectedFilter)
        
        // set background colour
        self.filterIndex = indexPath.row // set global index for selected filter
        let cell = collectionView.cellForItem(at: indexPath)! as! ChooseFilterCollectionViewCell
        if self.filterIndex == indexPath.row {
            cell.filterBackground.backgroundColor = UIColor(red: 244/255, green: 233/255, blue: 209/255, alpha: 1)
        } else {
            cell.filterBackground.backgroundColor = UIColor.clear
        }
        
        // change filter button text
        UserDefaults.standard.setValue(selectedFilter.filterID, forKey: self.constants.CURRENTFILTERID)
        updateFilterButtonDelegate?.updateFilterButton()

        
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
