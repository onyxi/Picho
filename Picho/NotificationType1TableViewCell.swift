//
//  NotificationType1TableViewCell.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 24/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit

class NotificationType1TableViewCell: UITableViewCell {

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationImage: RoundedImage!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
