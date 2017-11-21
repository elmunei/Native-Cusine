//
//  FUser.swift
//  andika
//
//  Created by Elvis Tapfumanei on 10/6/17.
//  Copyright © 2017 Elvis Tapfumanei. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import NotificationBannerSwift
import ProgressHUD

class FUser {
    
    let objectId: String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    let email: String
    var fullname: String
    var username: String
    var avatar: String
    var location: String
    var friends: [String]
    
    let loginMethod: String
    
    //MARK: Initializers
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _email: String,_username: String, _fullname: String, _avatar: String = "",_location: String, _loginMethod: String, _friends: [String]) {
        
        objectId = _objectId
        pushId = _pushId
        
        createdAt = _createdAt
        updatedAt = _updatedAt
        
        email = _email
        username = _username
        fullname = _fullname
        avatar = _avatar
        location = _location
        friends = _friends
        
        loginMethod = _loginMethod
        
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        createdAt = dateFormatter().date(from: _dictionary[kCREATEDAT] as! String)!
        updatedAt = dateFormatter().date(from:_dictionary[kUPDATEDAT] as! String)!
        
        email = _dictionary[kEMAIL] as! String
        username = _dictionary[kUSERNAME] as! String
        fullname = _dictionary[kFULLNAME] as! String
        location = _dictionary[kCURRENTUSERLOCATION] as! String
        avatar = _dictionary[kAVATAR] as! String
        
        
        if let friend = _dictionary[kFRIEND] {
            
            friends = friend as! [String]
            
        } else {
            
            friends = []
        }
        
        
        loginMethod = _dictionary[kLOGINMETHOD] as! String
        
    }
    
    
    //MARK: Returning current user funcs
    
    class func currentId() -> String {
        
        return Auth.auth().currentUser!.uid
        
    }
    
    class func currentUser () -> FUser? {
        
        if Auth.auth().currentUser != nil {
            
            let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER)
            
            return FUser.init(_dictionary: dictionary as! NSDictionary)
        }
        
        return nil
        
    }
    
    
    
    //MARK: Login function
    
    class func loginUserWith(email: String, password: String, withBlock: @escaping (_ success: Bool) -> Void ) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (firUser, error) in
            
            if error != nil {
                
                // show alert message
                let banner = StatusBarNotificationBanner(title: error!.localizedDescription, style: .danger)
                banner.show()
                
                ProgressHUD.dismiss()
                
                withBlock(false)
                return
                
            } else {
                
                //get user from firebase
                fetchUser(userId: firUser!.uid, withBlock: { (success) in
                    
                    withBlock(success)
                })
            }
            
            
        })
        
        
    }
    
    //MARK: Register functions
    
    class func registerUserWith(email: String, password: String, fullname: String, username: String, location: String, avatar: String = "", withBlock: @escaping (_ success: Bool) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (firuser, error) in
            
            if error != nil {
                
                // show alert message
                let banner = StatusBarNotificationBanner(title: error!.localizedDescription, style: .danger)
                banner.show()
                
                ProgressHUD.dismiss()
                
                withBlock(false)
                return
            }
            
            let fUser = FUser(_objectId: firuser!.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: firuser!.email!, _username: username, _fullname: fullname, _avatar: avatar,_location: location, _loginMethod: kEMAIL, _friends: [])
            
            
            print(fullname)
            print(username)
            print(email)
            print(location)
            
            
            
            saveUserLocally(fUser: fUser)
            saveUserInBsckground(fUser: fUser)
            withBlock(true)
            
        })
        
    }
    
    
    //MARK: LogOut func
    
    class func logOutCurrentUser() {
        
        userDefaults.removeObject(forKey: "OneSignalId")
        removeOneSignalId()
        
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        try! Auth.auth().signOut()
        
    }
    
} //end of class funcs




//MARK: Save user funcs
func saveUserInBsckground(fUser: FUser, completion: @escaping (_ error: Error?) -> Void) {
    
    let ref = firebase.child(kUSER).child(fUser.objectId)
    
    ref.setValue(userDictionaryFrom(user: fUser)) { (error, ref) -> Void in
        
        completion(error)
        
    }
    
}

func saveUserInBsckground(fUser: FUser) {
    
    let ref = firebase.child(kUSER).child(fUser.objectId)
    
    ref.setValue(userDictionaryFrom(user: fUser))
    
}


func saveUserLocally(fUser: FUser) {
    
    UserDefaults.standard.set(userDictionaryFrom(user: fUser), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
    
}


//MARK: Fetch User funcs


func fetchUser(userId: String, withBlock: @escaping (_ success: Bool) -> Void) {
    
    firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observe(.value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            let user = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary
            
            
            userDefaults.setValue(user, forKeyPath: kCURRENTUSER)
            userDefaults.synchronize()
            
            withBlock(true)
            
        } else {
            
            withBlock(false)
        }
        
    })
    
}


//MARK: Helper funcs

func userDictionaryFrom(user: FUser) -> NSDictionary {
    
    let createdAt = dateFormatter().string(from: user.createdAt)
    let updatedAt = dateFormatter().string(from: user.updatedAt)
    
    return NSDictionary(objects: [user.objectId,  createdAt, updatedAt, user.email, user.loginMethod, user.pushId!, user.username, user.fullname, user.avatar,user.location, user.friends], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kPUSHID as NSCopying, kUSERNAME as NSCopying, kFULLNAME as NSCopying, kAVATAR as NSCopying,kCURRENTUSERLOCATION as NSCopying, kFRIEND as NSCopying])
    
}

func cleanupFirebaseObservers() {
    
    firebase.child(kUSER).removeAllObservers()
    firebase.child(kRECENT).removeAllObservers()
    firebase.child(kGROUP).removeAllObservers()
}


//MARK: Update current user funcs

func updateUser(withValues : [String : Any], withBlock: @escaping (_ success: Bool) -> Void) {
    
    
    let currentUser = FUser.currentUser()!
    
    let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary
    
    userObject.setValuesForKeys(withValues)
    
    let ref = firebase.child(kUSER).child(FUser.currentId())
    
    ref.updateChildValues(withValues, withCompletionBlock: {
        error, ref in
        
        if error != nil {
            // show alert message
            let banner = StatusBarNotificationBanner(title: "couldnt update user \(String(describing: error?.localizedDescription))", style: .danger)
            banner.show()
            
            ProgressHUD.dismiss()
            withBlock(false)
            return
        }
        
        //update current user
        userDefaults.setValue(userObject, forKeyPath: kCURRENTUSER)
        userDefaults.synchronize()
        
        withBlock(true)
        
    })
}




//MARK: OneSignal

func updateOneSignalId() {
    
    if FUser.currentUser() != nil {
        
        if let pushId = UserDefaults.standard.string(forKey: "OneSignalId") {
            
            setOneSignalId(pushId: pushId)
            
        } else {
            
            removeOneSignalId()
        }
    }
}


func setOneSignalId(pushId: String) {
    
    updateCurrentUserOneSignalId(newId: pushId)
}


func removeOneSignalId() {
    
    updateCurrentUserOneSignalId(newId: "")
}

//MARK: Updating Current user funcs

func updateCurrentUserOneSignalId(newId: String) {
    
    let user = FUser.currentUser()
    user!.pushId = newId
    user!.updatedAt = Date()
    
    saveUserLocally(fUser: user!)
    saveUserInBsckground(fUser: user!)
}

func updateCurrentUserAvatar(newAvatar: String) {
    
    let user = FUser.currentUser()
    user!.avatar = newAvatar
    user!.updatedAt = Date()
    
    saveUserLocally(fUser: user!)
    saveUserInBsckground(fUser: user!)
}
