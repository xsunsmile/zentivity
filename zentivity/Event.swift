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
//    @NSManaged var invited: PFRelation
    @NSManaged var invitedUsers: NSMutableArray
    @NSManaged var confirmed: PFRelation
    @NSManaged var declined: PFRelation
    @NSManaged var comments: PFRelation
    @NSManaged var photos: PFRelation
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
    
    func saveWithCompletion(completion: (success: Bool!, error: NSError!) -> ()) {
        if let invitedUsernames = invitedUsernames {
            ParseClient.usersWithCompletion(invitedUsernames, completion: { (users, error) -> () in
                for user in users { self.invitedUsers.addObject(user.objectId) }
                self.saveInBackgroundWithBlock { (success, error) -> Void in
                    completion(success: success, error: error)
                }
            })
        } else {
            saveInBackgroundWithBlock { (success, error) -> Void in
                completion(success: success, error: error)
            }
        }
        
    }
    
    func addPhotoWithCompletion(image: UIImage, completion: (success: Bool!, error: NSError!) -> ()) {
        var photo = Photo()
        photo.user = PFUser.currentUser()
        photo.file = PFFile(name:"image.png", data: UIImagePNGRepresentation(image))
        photo.saveInBackgroundWithBlock { (success, error) -> Void in
            if success == true {
                self.photos.addObject(photo)
                self.saveInBackgroundWithBlock({ (success, error) -> Void in
                    completion(success: success, error: error)
                })
            } else {
                completion(success: success, error: error)
            }
        }
    }
    
    func addCommentWithCompletion(text: String, completion: (success: Bool!, error: NSError!) -> ()) {
        var comment = Comment()
        comment.user = PFUser.currentUser()
        comment.text = text
        comment.saveInBackgroundWithBlock { (success, error) -> Void in
            if success == true {
                self.comments.addObject(comment)
                self.saveInBackgroundWithBlock({ (success, error) -> Void in
                    completion(success: success, error: error)
                })
            } else {
                completion(success: success, error: error)
            }
        }
    }
    
    func photosWithCompletion(completion: (photos: [Photo], error: NSError!) -> ()) {
        let query = photos.query()
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(photos: objects as [Photo], error: error)
        }
    }
    
    func commentsWithCompletion(completion: (comments: [Comment], error: NSError!) -> ()) {
        let query = comments.query()
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(comments: objects as [Comment], error: error)
        }
    }
    
    func confirmWithCompletion(eventcompletion: (success: Bool!, error: NSError!) -> ()) {
        
    }
}