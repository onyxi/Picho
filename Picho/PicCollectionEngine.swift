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
    
    
    
    // initialise animation engine and recieve constraints to animate
    init (pastCollectionX: NSLayoutConstraint, futureCollectionX: NSLayoutConstraint) {
        
        ////////// set initial position of views //////////
        
        self.pastCollectionCon = pastCollectionX
        self.futureCollectionCon = futureCollectionX
        
        setViewStartPosition()
        
        
        
    }
    
    
    func setViewStartPosition() {
        self.pastCollectionCon.constant = PicCollectionEngine.screenCenterPosition
        self.futureCollectionCon.constant = PicCollectionEngine.screenRightPosition
    }
    
    
    
    
    
    
    /// define coordinates of centre-screen, off-screen-right and off-screen-left positions for display objects
    
    class var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    class var screenLeftPosition: CGFloat {
        return 0 - screenWidth
    }
    
    class var screenCenterPosition: CGFloat {
        return 0
    }
    
    class var screenRightPosition: CGFloat {
        return screenWidth
    }
    
    
    
    // animate items
    
    func switchViews(showView: String) {
        
        var pastNewDestination: CGFloat!
        var futureNewDestination: CGFloat!
        
        switch showView {
        case "past":
            pastNewDestination = PicCollectionEngine.screenCenterPosition
            futureNewDestination = PicCollectionEngine.screenRightPosition
        case "future":
            pastNewDestination = PicCollectionEngine.screenLeftPosition
            futureNewDestination = PicCollectionEngine.screenCenterPosition
        default:
            break
        }
        
        
        let movePast = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        movePast?.springBounciness = 0
        movePast?.springSpeed = 20
        movePast?.toValue = pastNewDestination
        pastCollectionCon.pop_add(movePast, forKey: "movePastCollectionToNewPosition")
        
        let moveFuture = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        moveFuture?.springBounciness = 0
        moveFuture?.springSpeed = 20
        moveFuture?.toValue = futureNewDestination
        futureCollectionCon.pop_add(moveFuture, forKey: "moveFutureCollectionToNewPosition")
        
    }
    
    
    
    
    
}

