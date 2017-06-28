//
//  PicCollectionEngine.swift
//
//  Created by Pete on 09/01/2017.
//  Copyright © 2017 Pete. All rights reserved.
//

import Foundation
import pop

class PicCollectionEngine {
    
    var pastCollectionCon: NSLayoutConstraint!
    var futureCollectionCon: NSLayoutConstraint!
    
    // initialise animation engine, recieve constraints to animate and set initial position of views
    init (pastCollectionX: NSLayoutConstraint, futureCollectionX: NSLayoutConstraint) {
        self.pastCollectionCon = pastCollectionX
        self.futureCollectionCon = futureCollectionX
        self.pastCollectionCon.constant = screenCenterPosition
        self.futureCollectionCon.constant = screenRightPosition
    }
    
    /// define coordinates of centre-screen, off-screen-right and off-screen-left positions for display objects
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var screenLeftPosition: CGFloat {
        return 0 - screenWidth
    }
    
    var screenCenterPosition: CGFloat {
        return 0
    }
    
    var screenRightPosition: CGFloat {
        return screenWidth
    }
    
    
    
    // animate collection view objects - toggle to left/right screen
    func switchViews(showView: String) {
        
        var pastNewDestination: CGFloat!
        var futureNewDestination: CGFloat!
        
        switch showView {
        case "past":
            pastNewDestination = screenCenterPosition
            futureNewDestination = screenRightPosition
        case "future":
            pastNewDestination = screenLeftPosition
            futureNewDestination = screenCenterPosition
        default:
            break
        }
        
        let movePastCollection = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        movePastCollection?.springBounciness = 0
        movePastCollection?.springSpeed = 20
        movePastCollection?.toValue = pastNewDestination
        pastCollectionCon.pop_add(movePastCollection, forKey: "movePastCollectionToNewPosition")
        
        let moveFutureCollection = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        moveFutureCollection?.springBounciness = 0
        moveFutureCollection?.springSpeed = 20
        moveFutureCollection?.toValue = futureNewDestination
        futureCollectionCon.pop_add(moveFutureCollection, forKey: "moveFutureCollectionToNewPosition")
        
    }
    
    
}

