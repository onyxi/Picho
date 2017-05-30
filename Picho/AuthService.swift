//
//  AuthService.swift
//  Picho
//
//  Created by Pete on 09/03/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//



import Foundation
import FirebaseAuth

// typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    static var instance: AuthService {
        return _instance
    }
    
    var fetchDataAfterLogin: FetchDataAfterLogInDelegate?
    
    
    func createAccount(email: String, password: String, onComplete: Completion?) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                // show error to user
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                // login and advance to app
                if user?.uid != nil {
                    DataService.instance.createNewUser(uid: user!.uid, email: email, password: password, username: email)
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                        if error != nil {
                            // show error to user
                            self.handleFirebaseError(error: error as! NSError, onComplete: onComplete)
                        }
                        // we have successfully logged in
                        onComplete?(nil, user)
                        UserDefaults.standard.set(true, forKey: "userLoggedInToFirebase")
                        DataService.instance.getAndStoreLoggedInUserInfo(userID: user!.uid, loggingIn: true)
                    })
                    
                } else {
                    // there was a problem getting user.uid!
                }
            }
        })
    }
    
    
    func login(email: String, password: String, onComplete: Completion?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else {
                // we have successfully logged in
                onComplete?(nil, user)
                UserDefaults.standard.set(true, forKey: "userLoggedInToFirebase")
                DataService.instance.getAndStoreLoggedInUserInfo(userID: user!.uid, loggingIn: true)
            }
        })
        
        
    }
    
    
    
    ///// refactor create/login functions to make login function which also retrieves user info for local use
    
    // func login () {
    //
    // }
    
    
    
    func handleFirebaseError (error: NSError, onComplete: Completion?) {
        print (error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error._code) {
            switch (errorCode) {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("Invalid Password", nil)
                break
            case .errorCodeEmailAlreadyInUse:
                onComplete?("Email already in use", nil)
            case .errorCodeUserNotFound:
                onComplete?("Account not found", nil)
            default:
                onComplete?("There was a problem authenticating, please try again", nil)
                break
            }
            
        }
    }
    
    
    
    
}
