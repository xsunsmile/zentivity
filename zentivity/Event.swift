////
////  Event.swift
////  zentivity
////
////  Created by Eric Huang on 3/7/15.
////  Copyright (c) 2015 Zendesk. All rights reserved.
////

class Event : PFObject, PFSubclassing {
    @NSManaged var title: String
    @NSManaged var descript: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate
    @NSManaged var admin: PFUser
    @NSManaged var invitedUsers: NSMutableArray
    @NSManaged var confirmedUsers: NSMutableArray
    @NSManaged var declinedUsers: NSMutableArray
    @NSManaged var comments: NSMutableArray?
    @NSManaged var photos: NSMutableArray?
    
    var invitedUsernames: [String]?
    var dateFormatter = NSDateFormatter()
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String! {
        return "Event"
    }
    
    class func listWithCompletion(completion: (events: [Event]?, error: NSError!) -> ()) {
        var query = Event.query()
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                let events = objects as [Event]
                completion(events: events, error: nil)
            } else {
                completion(events: nil, error: error)
            }
        }
    }
    
    func userJoined(user: User?) -> Bool {
        if let user = user {
            return confirmedUsers.containsObject(user)
        } else {
            return false
        }
    }
    
    func startTimeWithFormat(format: NSString?) -> NSString {
        if format == nil {
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        } else {
            dateFormatter.dateFormat = format
        }
        return dateFormatter.stringFromDate(startTime)
    }
    
    func createWithCompletion(completion: (success: Bool!, error: NSError!) -> ()) {
        self.admin = PFUser.currentUser()
        self.confirmedUsers = []
        self.declinedUsers = []
        if photos == nil { self.photos = [] }
        
        if let invitedUsernames = invitedUsernames {
            ParseClient.usersWithCompletion(invitedUsernames, completion: { (users, error) -> () in
                self.setObject(users, forKey: "invitedUsers")
                self.saveInBackgroundWithBlock { (success, error) -> Void in
                    completion(success: success, error: error)
                }
            })
        } else {
            self.invitedUsers = []
            saveInBackgroundWithBlock { (success, error) -> Void in
                completion(success: success, error: error)
            }
        }
    }
    
    func addPhotoWithCompletion(image: UIImage, completion: (success: Bool!, error: NSError!) -> ()) {
        var photo = Photo()
        photo.user = PFUser.currentUser()
        photo.file = PFFile(name:"image.png", data: UIImagePNGRepresentation(image))

        if self.photos == nil { self.photos = NSMutableArray() }
        self.photos!.addObject(photo)
        
        self.saveInBackgroundWithBlock({ (success, error) -> Void in
            completion(success: success, error: error)
        })
    }
    
    func addCommentWithCompletion(text: String, completion: (success: Bool!, error: NSError!) -> ()) {
        var comment = Comment()
        comment.user = PFUser.currentUser()
        comment.text = text
        
        if self.comments == nil { self.comments = NSMutableArray() }
        self.comments!.addObject(comment)
        
        self.saveInBackgroundWithBlock({ (success, error) -> Void in
            completion(success: success, error: error)
        })
    }
}