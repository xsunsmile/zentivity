//
//  GoogleClient.swift
//  zentivity
//
//  Created by Hao Sun on 3/7/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
let userDidLoginNotification = "userDidLoginNotification"
let userLoginFailedNotification = "userLoginFailedNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class GoogleClient: NSObject,
                    GPPSignInDelegate
{
    let clientId = "502965285809-1aoq6sfjm9v9q6nvnrbbatnef1cojrv8.apps.googleusercontent.com"
    let scopes =  ["https://www.googleapis.com/auth/plus.login"]
    let signIn = GPPSignIn.sharedInstance()
    let plusService = GTLServicePlus()
    var loginCompletion: ((Bool) -> Void)?
    
    class var sharedInstance: GoogleClient {
        struct Singleton {
            static let instance = GoogleClient()
        }
        return Singleton.instance
    }
    
    override init() {
        signIn.shouldFetchGooglePlusUser = true
        signIn.shouldFetchGoogleUserEmail = true
        signIn.clientID = clientId
        signIn.scopes = scopes
        
        plusService.retryEnabled = true
    }
    
    func alreadyLogin() -> Bool {
        return signIn.authentication != nil || signIn.trySilentAuthentication()
    }
    
    func loginWithCompletion(completion: (completed: Bool) -> Void) {
        signIn.delegate = self
        loginCompletion = completion
        
        if !signIn.trySilentAuthentication() {
            signIn.authenticate()
        } else {
            initGooglePlusService()
            getCurrentUserProfileWithCompletion({ (userInfo, error) -> () in
                if error == nil {
                    completion(completed: true)
                }
            })
        }
    }
    
    func logoutWithCompletion(completion: (completed: Bool) -> Void) {
        if alreadyLogin() {
            signIn.signOut()
            completion(completed: true)
        }
    }
    
    func initGooglePlusService() {
        plusService.authorizer = signIn.authentication
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if auth != nil {
            initGooglePlusService()
            getCurrentUserProfileWithCompletion({ (userInfo, error) -> () in
                if error == nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(userDidLoginNotification, object: nil, userInfo: userInfo! as [NSObject : AnyObject])
                }
            })
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(userLoginFailedNotification, object: error)
        }
        
        if (loginCompletion != nil) {
            loginCompletion!(auth != nil)
        }
    }
    
    func getCurrentUserProfileWithCompletion(completion: (userInfo: NSMutableDictionary?, error: NSError?) -> ()) {
        let userInfo = NSMutableDictionary()
        let query = GTLQueryPlus.queryForPeopleGetWithUserId("me") as! GTLQueryPlus
        
        plusService.executeQuery(query, completionHandler: { (ticket, person, error) -> Void in
            if error != nil {
                NSLog("Can not get current user profile: %@", error)
                completion(userInfo: nil, error: error)
            } else {
                let user = person as! GTLPlusPerson
                NSLog("user %@", user)
                NSLog("user name: %@, about: %@", user.displayName, user.name)
                
                let email = user.emails[0] as! GTLPlusPersonEmailsItem
                userInfo["email"] = email.value

                userInfo["email"] = email.value
                userInfo["name"] = (user.displayName != nil ? user.displayName : "")
                userInfo["imageUrl"] = (user.image != nil ? user.image.url : "")
                userInfo["aboutMe"] = (user.aboutMe != nil ? user.aboutMe : "")
                completion(userInfo: userInfo, error: nil)
            }
        })
    }
}
