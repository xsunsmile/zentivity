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
}