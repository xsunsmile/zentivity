//
//  ParseClient.swift
//  zentivity
//
//  Created by Eric Huang on 3/6/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    // Sign up user
    // Required params: [username, password]
    // Optional params: [email]
    class func signupWithCompletion(params: NSDictionary!, completion: (user: PFUser?, error: NSError?) ->()) {
        var user = PFUser()
        
        user.username = params["username"] as? String
        user.password = params["password"] as? String
        user.email = params["email"] as? String
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                completion(user: user, error: nil)
            } else {
                completion(user: nil, error: error)
            }
        }
    }
    
    // Log in user
    // Required params: [username, password]
    class func loginWithCompletion(params: NSDictionary!, completion: (user: PFUser?, error: NSError?) ->()) {
        let username = params["username"] as? String
        let password = params["password"] as? String
        
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                completion(user: user, error: nil)
            } else {
                completion(user: nil, error: error)
            }
        }
    }
    
    // Users
    // Give list of usernames to get users
    // Used for relations
    class func usersWithCompletion(usernames: [String], completion: (users: [PFUser]?, error: NSError?) -> ()) {
        var query = PFQuery(className:"_User")
        query.whereKey("username", containedIn: usernames)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                completion(users: objects as? [PFUser], error: nil)
            } else {
                completion(users: nil, error: error)
            }
        }
    }
}