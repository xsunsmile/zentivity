////
////  User.swift
////  zentivity
////
////  Created by Eric Huang on 3/7/15.
////  Copyright (c) 2015 Zendesk. All rights reserved.
////

let kUserJoinEvent = "userJoinEvent"
let kUserCancelEvent = "userCancelEvent"

class User : PFUser, PFSubclassing {
    @NSManaged var name: String
    @NSManaged var aboutMe: String
    @NSManaged var imageUrl: String
    @NSManaged var contactNumber: String
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
            println("INITING _USER")
        }
    }
    
    class func allWithCompletion(completion: (users: [User]?, success: Bool) -> Void) {
        var query = User.query()
        query.findObjectsInBackgroundWithBlock { (users, error) -> Void in
            if error == nil {
                let users = users as [User]
                completion(users: users, success: true)
            } else {
                completion(users: nil, success: false)
            }
        }
    }
    
    func toggleJoinEventWithCompletion(event: Event, completion: (success: Bool!, error: NSError!, state: NSString) -> ()) {
        if event.userJoined(self) {
            quitEventWithCompletion(event, completion)
        } else {
            joinEventWithCompletion(event, completion)
        }
    }
    
    func joinEventWithCompletion(event: Event, completion: (success: Bool!, error: NSError!, state: NSString) -> ()) {
        confirmEvent(event, completion: { (success, error) -> () in
            completion(success: success, error: error, state: kUserJoinEvent)
        })
    }
    
    func quitEventWithCompletion(event: Event, completion: (success: Bool!, error: NSError!, state: NSString) -> ()) {
        declineEvent(event, completion: { (success, error) -> () in
            completion(success: success, error: error, state: kUserCancelEvent)
        })
    }
    
    func eventsWithCompletion(type: String!, completion: (events: [Event], error: NSError!) -> ()) {
        let query = Event.query()
        query.whereKey(type, equalTo: self)
        query.orderByDescending("startTime")
//        query.includeKey("photos")
        query.includeKey("confirmedUsers")
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                completion(events: objects as [Event], error: nil)
            } else {
                completion(events: [], error: error)
            }
        }
    }
    
    func confirmEvent(event: Event, completion: (success: Bool!, error: NSError!) -> ()) {
        var query = Event.query()
        query.getObjectInBackgroundWithId(event.objectId) {
            (gameScore: PFObject!, error: NSError!) -> Void in
            if error == nil {
                // Remove self from confirmed users
                for confirmedUser in event.confirmedUsers {
                    if confirmedUser.objectId == self.objectId {
                        event.confirmedUsers.removeObject(confirmedUser)
                    }
                }
                // Remove self from declined users
                for declinedUser in event.declinedUsers {
                    if declinedUser.objectId == self.objectId {
                        event.declinedUsers.removeObject(declinedUser)
                    }
                }
                event.confirmedUsers.addObject(self)
                
                event.saveInBackgroundWithBlock({ (success, error) -> Void in
                    completion(success: success, error: nil)
                })
            } else {
                println("Could not find the event")
                completion(success: false, error: NSError())
            }
        }
    }
    
    func declineEvent(event: Event, completion: (success: Bool!, error: NSError!) -> ()) {
        var query = Event.query()
        
        query.getObjectInBackgroundWithId(event.objectId) {
            (gameScore: PFObject!, error: NSError!) -> Void in
            if error == nil {
                // Remove self from confirmed users
                for confirmedUser in event.confirmedUsers {
                    if confirmedUser.objectId == self.objectId {
                        event.confirmedUsers.removeObject(confirmedUser)
                    }
                }
                // Remove self from declined users
                for declinedUser in event.declinedUsers {
                    if declinedUser.objectId == self.objectId {
                        event.declinedUsers.removeObject(declinedUser)
                    }
                }
                event.declinedUsers.addObject(self)
                event.saveInBackgroundWithBlock({ (success, error) -> Void in
                    completion(success: success, error: nil)
                })
            } else {
                println("Could not find the event")
                completion(success: false, error: NSError())
            }
        }
    }
    
    func initialsImageView(imageSize: CGSize!) -> UIImage {
        var firstName: NSString!
        var lastName: NSString!
        let names = name.componentsSeparatedByString(" ")
        
            if names.count >= 2 {
                firstName = names.first!
                lastName = names.last!
            } else {
                firstName = name
                lastName = name
            }
//        } else {
//            let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "X", "Y", "Z"]
//            let randomInt1 = Int(arc4random_uniform(27))
//            let randomInt2 = Int(arc4random_uniform(27))
//            firstName = letters[randomInt1]
//            lastName = letters[randomInt2]
//        }
        
        let initials = UserInitialsView.initialsForFirstName(firstName, lastName: lastName)
        let frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
        let initView = UserInitialsView(frame: frame, initials: initials, fontSize: 12, drawOffsetFromCenter: CGPointZero)
        return initView.convertToImage()
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