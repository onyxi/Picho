//
//  Filter.swift
//  Picho
//
//  Created by Pete on 02/07/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class Filter {
    
    // declare Media object properties
    var filterID: Int
    var name: String
    var lastSelected: Date
    
    // initialize Media object
    init(filterID: Int, name: String, lastSelected: Date) {
        self.filterID = filterID
        self.name = name
        self.lastSelected = lastSelected
    }
    
}
