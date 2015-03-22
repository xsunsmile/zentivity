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
    
    class func setUpUserWithCompletion(user: User, completion: (user: User?, error: NSError?) -> ()) {
        if user.contactNumber == nil {
            user.contactNumber = self.randomPhoneNumber()
        }
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                println("Signed up user with username")
                completion(user: user as User, error: nil)
            } else {
                User.logInWithUsernameInBackground(user.username, password: user.password, block: { (user, error) -> Void in
                    if error == nil {
                        println("Logged in user with username")
                        completion(user: user as? User, error: nil)
                    } else {
                        completion(user: nil, error: error)
                    }
                })
            }
        }
    }
    
    class func randomPhoneNumber() -> String {
        var randomNumber = "(415) "
        for i in 0...7 {
            if i == 3 {
                randomNumber += "-"
            } else {
                let randomDigit = arc4random_uniform(10)
                randomNumber += String(randomDigit)
            }
        }
        
        return randomNumber
    }
}