////
////  User.swift
////  zentivity
////
////  Created by Eric Huang on 3/7/15.
////  Copyright (c) 2015 Zendesk. All rights reserved.
////

class User : PFUser, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    func eventsWithCompletion(type: String!, completion: (events: [Event], error: NSError!) -> ()) {
        let query = Event.query()
        query.whereKey(type, equalTo: self)
        query.includeKey("photos")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(events: objects as [Event], error: error)
        }
    }
}