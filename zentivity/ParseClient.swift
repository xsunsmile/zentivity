//
//  ParseClient.swift
//  zentivity
//
//  Created by Eric Huang on 3/6/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    // Users
    // Give list of usernames to get users
    // Used for relations
    class func usersWithCompletion(usernames: [String], completion: (users: [PFUser], error: NSError?) -> ()) {
        var query = PFQuery(className:"_User")
        query.whereKey("username", containedIn: usernames)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                completion(users: objects as [PFUser], error: nil)
            } else {
                completion(users: [], error: error)
            }
        }
    }
    
    class func authWithCompletion(googleUser: GTLPlusPerson, completion: (user: User?, error: NSError?) -> ()) {
        var user = User()
        user.username = googleUser.displayName
        user.email = googleUser.emails[0] as String
        user.password = "1"
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if success {
                println("Successfully signed up with Parse")
                completion(user: user, error: nil)
            } else {
                println("Failed to sign up with Parse")
                User.logInWithUsernameInBackground(googleUser.displayName, password: "1", block: { (user, error) -> Void in
                    if error == nil {
                        println("Logged in with Parse")
                        completion(user: user as? User, error: nil)
                    } else {
                        println("Failed to log in with Parse")
                        completion(user: nil, error: error)
                    }
                })
            }
        }
        
    }
}