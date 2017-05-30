//
//  GalleryCoverCollectionViewCell.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 02/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import CoreData

protocol AlbumDetailsButtonDelegate {
    func albumDetailsButtonPressed ()
}


class GalleryCoverCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var albumCoverAvailableDate: UILabel!
    @IBOutlet weak var albumCoverImageCount: UILabel!
    @IBOutlet weak var albumCoverDescription: UILabel!
    
    
    var delegate: AlbumDetailsButtonDelegate?
    
    
    @IBAction func detailsButtonPressed(_ sender: Any) {
        
        delegate?.albumDetailsButtonPressed()
        
    }
    

    
}
