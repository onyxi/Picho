//
//  AnimationEngine.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 29/08/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
import pop

class AnimationEngine {
    
    var set1Constraints: [NSLayoutConstraint]!
    var set2Constraints: [NSLayoutConstraint]!
    
    /// initialise Animation Engine and populate arrays to hold constraint sets 1 & 2 for animation
    init (set1Constraints: [NSLayoutConstraint], set2Constraints: [NSLayoutConstraint]) {
        for con in set1Constraints {
            con.constant = AnimationEngine.offScreenRightPosition.x
        }
        self.set1Constraints = set1Constraints
        
        for con in set2Constraints {
            con.constant = AnimationEngine.offScreenRightPosition.x
        }
        self.set2Constraints = set2Constraints
    }
    
    
    
    
    /// define coordinates of centre-screen, off-screen-right and off-screen-left positions for display objects
    class var screenCenterPosition: CGPoint {
        return CGPointMake(0.0, CGRectGetMidY(UIScreen.mainScreen().bounds))
    }
    
    class var offScreenRightPosition: CGPoint {
        return CGPointMake(UIScreen.mainScreen().bounds.width, CGRectGetMidY(UIScreen.mainScreen().bounds))
    }
    
    class var offScreenLeftPosition: CGPoint {
        return CGPointMake(-UIScreen.mainScreen().bounds.width, CGRectGetMidY(UIScreen.mainScreen().bounds))
    }
    
    
    
    /// main function to animate display objects
    func animateLogInObjects(delay: Float, set1Destination: String, set2Destination: String) {
        
        /// declare variables to hold x coordinate for objects to animate to
        var set1NewPosition: CGPoint!
        var set2NewPosition: CGPoint!
        
        /// update set 1 new X coordinate to reflect function parameter
        switch set1Destination {
            case "left":
                set1NewPosition = AnimationEngine.offScreenLeftPosition
            case "centre":
                set1NewPosition = AnimationEngine.screenCenterPosition
            case "right":
                set1NewPosition = AnimationEngine.offScreenRightPosition
            default:
                set1NewPosition = AnimationEngine.offScreenRightPosition
        }
        
        /// update set 2 new X coordinate to reflect function parameter
        switch set2Destination {
            case "left":
                set2NewPosition = AnimationEngine.offScreenLeftPosition
            case "centre":
                set2NewPosition = AnimationEngine.screenCenterPosition
            case "right":
                set2NewPosition = AnimationEngine.offScreenRightPosition
            default:
                set2NewPosition = AnimationEngine.offScreenRightPosition
        }

        /// trigger animation after delay provided in function parameter
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay) * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            
            /// assign pop animations to set 1 objects
            var index = 0
            for _ in self.set1Constraints {
                let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                moveAnim.springBounciness = 12
                moveAnim.springSpeed = 12
                moveAnim.toValue = set1NewPosition.x
                let conToAnimate = self.set1Constraints[index]
                conToAnimate.pop_addAnimation(moveAnim, forKey: "moveSet1ToNewPosition")
                index += 1
            }
            
            /// assign pop animations to set 2 objects
            index = 0
            for _ in self.set2Constraints {
                let moveAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                moveAnim.springBounciness = 12
                moveAnim.springSpeed = 12
                moveAnim.toValue = set2NewPosition.x
                let conToAnimate = self.set2Constraints[index]
                conToAnimate.pop_addAnimation(moveAnim, forKey: "moveSet2ToNewPosition")
                index += 1
            }
            
        }
        
        
    }

    
    
}