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
    @NSManaged var comments: [Comment]?
    @NSManaged var photos: [Photo]?
    var invitedUsernames: [String]?
    
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
    
    func createWithCompletion(completion: (success: Bool!, error: NSError!) -> ()) {
        self.admin = PFUser.currentUser()
        self.confirmedUsers = []
        self.declinedUsers = []
        
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
        
        var newPhotos: NSMutableArray = [photo]
        if self.photos != nil {
            newPhotos.addObjectsFromArray(self.photos!)
        }
        
        self.setObject(newPhotos, forKey: "photos")
        self.saveInBackgroundWithBlock({ (success, error) -> Void in
            completion(success: success, error: error)
        })
    }
    
    func addCommentWithCompletion(text: String, completion: (success: Bool!, error: NSError!) -> ()) {
        var comment = Comment()
        comment.user = PFUser.currentUser()
        comment.text = text
        
        var newComments: NSMutableArray = [comment]
        if self.comments != nil {
            newComments.addObjectsFromArray(self.comments!)
        }
        
        self.setObject(newComments, forKey: "comments")
        self.saveInBackgroundWithBlock({ (success, error) -> Void in
            completion(success: success, error: error)
        })
    }
}