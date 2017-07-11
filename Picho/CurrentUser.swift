//
//  CurrentUser.swift
//  Picho
//
//  Created by Pete on 12/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

class CurrentUser: User {
    
    // declare additional CurrentUser object properties
    var password: String
   
    // intialise CurrentUser object
    init() {
        let constants = Constants()
        
        print(UserDefaults.standard.value(forKey: constants.USER_PASSWORD) as! String)
        self.password = UserDefaults.standard.value(forKey: constants.USER_PASSWORD) as! String

        super.init(
            userID: UserDefaults.standard.value(forKey: constants.USER_ID) as! String,
            username: UserDefaults.standard.value(forKey: constants.USER_USERNAME) as! String,
            email: UserDefaults.standard.value(forKey: constants.USER_EMAIL) as! String,
            profilePicURL: UserDefaults.standard.value(forKey: constants.USER_PROFILEPICURL) as! String
        )
    }

}
