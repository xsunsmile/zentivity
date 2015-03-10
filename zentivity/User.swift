////
////  User.swift
////  zentivity
////
////  Created by Eric Huang on 3/7/15.
////  Copyright (c) 2015 Zendesk. All rights reserved.
////

var _googleUser: User?
let currentUserKey = "kGoogleUserKey"

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
        query.includeKey("comments")
        query.includeKey("invitedUsers")
        query.includeKey("confirmedUsers")
        query.includeKey("declinedUsers")
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(events: objects as [Event], error: error)
        }
    }
    
    func confirmEvent(event: Event, completion: (success: Bool!, error: NSError!) -> ()) {
        var eventsQuery = Event.query()
        eventsQuery.whereKey("invitedUsers", equalTo: self)
        eventsQuery.whereKey("confirmedUsers", notEqualTo: self)
        eventsQuery.whereKey("objectId", equalTo: event.objectId)
        
        eventsQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil && objects.count == 1 {
                event.confirmedUsers.addObject(self)
                for declinedUser in event.declinedUsers {
                    if declinedUser.objectId == self.objectId {
                        event.declinedUsers.removeObject(declinedUser)
                    }
                }
                event.saveInBackgroundWithBlock({ (success, error) -> Void in
                    completion(success: success, error: nil)
                })
            } else {
                completion(success: false, error: NSError())
            }
        })
    }
    
    func declineEvent(event: Event, completion: (success: Bool!, error: NSError!) -> ()) {
        var eventsQuery = Event.query()
        eventsQuery.whereKey("invitedUsers", equalTo: self)
        eventsQuery.whereKey("declineUsers", notEqualTo: self)
        eventsQuery.whereKey("objectId", equalTo: event.objectId)
        
        eventsQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil && objects.count == 1 {
                event.declinedUsers.addObject(self)
                for confirmedUser in event.confirmedUsers {
                    if confirmedUser.objectId == self.objectId {
                        event.confirmedUsers.removeObject(confirmedUser)
                    }
                }
                event.saveInBackgroundWithBlock({ (success, error) -> Void in
                    completion(success: success, error: nil)
                })
            } else {
                completion(success: false, error: NSError())
            }
        })
    }
    
    // Auth stuff
    
    class func logoutWithCompletion(completion: (completed: Bool) -> Void) {
        GoogleClient.sharedInstance.logoutWithCompletion { (completed) -> Void in
            if completed == true {
                User.logOut()
                completion(completed: true)
            } else {
                completion(completed: false)
            }
        }
    }
}