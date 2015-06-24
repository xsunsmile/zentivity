//
//  ZenEvent.swift
//  zentivity
//
//  Created by Hao Sun on 5/20/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

// {
//id: 1,
//description: "This is a Hackaton.",
//time: "2015-05-14T05:49:30.000Z",
//capacity: 600,
//duration: 1440,
//organization_id: 1,
//created_at: "2015-05-14T04:49:30.000Z",
//updated_at: "2015-05-14T04:49:30.000Z",
//title: "Zendesk Hackaton.",
//event_type_id: 1,
//organization: {
//    id: 1,
//    name: "Zendesk",
//    description: "Test Organization.",
//    location: "989 Market St, San Francisco CA, 94103",
//    website: "www.zendesk.com",
//    created_at: "2015-05-14T04:49:30.000Z",
//    updated_at: "2015-05-14T04:49:30.000Z"
//},
//volunteers: [
//{
//id: 1,
//name: "Agent Extraordinaire",
//email: "agent1@zendesk.com",
//created_at: "2015-05-14T04:49:30.000Z",
//updated_at: "2015-05-14T04:49:30.000Z"
//},
//{
//id: 2,
//name: "Extraordinaire Agent",
//email: "agent2@zendesk.com",
//created_at: "2015-05-14T04:49:30.000Z",
//updated_at: "2015-05-14T04:49:30.000Z"
//}
//],
//start: "2015-05-14T05:49:30.000Z",
//end: "2015-05-15T05:49:30.000Z"
//}

class ZenEvent {
    
    var confirmedUsers: NSMutableArray = []
    var dateFormatter = NSDateFormatter()
    var startTime: NSDate = NSDate()
    var endTime: NSDate = NSDate()
    var title: String = ""
    var lowercaseTitle: String = ""
    var descript: String = ""
    var capacity: NSInteger = 0
    var photos: NSMutableArray = []
    var locationString: String = ""
    
    class func listWithOptionsAndCompletion(options: NSDictionary?, completion: (events: [ZenEvent]?, error: NSError?) -> ()) {
        ZendeskClient.sharedInstance.getWithCompletion("events", params: options) { (result, error) -> Void in
            if let result = result as? NSArray {
                var events: [ZenEvent]? = []
                for eventDict in result {
                    events!.append(ZenEvent(dictionary: eventDict as! NSDictionary))
                }
                completion(events: events, error: nil)
            } else {
                completion(events: nil, error: error)
            }
        }
    }
    
    init(dictionary: NSDictionary) {
        title = dictionary["title"] as! String
        descript = dictionary["description"] as! String
        capacity = dictionary["capacity"] as! NSInteger
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
        startTime = dateFormatter.dateFromString(dictionary["start"] as! String)!
        endTime = dateFormatter.dateFromString(dictionary["end"] as! String)!
    }
    
    func userJoined(user: User?) -> Bool {
        if let user = user {
            for confirmedUser in confirmedUsers {
                if confirmedUser.objectId == user.objectId {
                    return true
                }
            }
            return false
        } else {
            return false
        }
    }
    
    func ownedByUser(user: User?) -> Bool {
        return false
    }
    
    func startTimeWithFormat(format: NSString?) -> NSString {
        if let format = format {
            dateFormatter.dateFormat = "\(format)"
        } else {
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        }
        return dateFormatter.stringFromDate(startTime)
    }
    
    func createWithCompletion(completion: (success: Bool!, error: NSError!) -> ()) {
        // self.admin = PFUser.currentUser()!
        // self.confirmedUsers = [self.admin]
        // self.declinedUsers = []
        self.lowercaseTitle = title.lowercaseString
        // if photos == nil { self.photos = [] }
        
//        if let invitedUsernames = invitedUsernames {
//            ParseClient.usersWithCompletion(invitedUsernames, completion: { (users, error) -> () in
//                self.setObject(users, forKey: "invitedUsers")
//                self.saveInBackgroundWithBlock { (success, error) -> Void in
//                    completion(success: success, error: error)
//                }
//            })
//        } else {
//            self.invitedUsers = []
//            saveInBackgroundWithBlock { (success, error) -> Void in
//                completion(success: success, error: error)
//            }
//        }
    }
    
    func addPhotoWithCompletion(image: UIImage, completion: (success: Bool!, error: NSError!) -> ()) {
        return
    }
    
    func addCommentWithCompletion(text: String, completion: (success: Bool!, error: NSError!) -> ()) {
        var comment = Comment()
        comment.user = PFUser.currentUser()!
        comment.text = text
        
//        if self.comments == nil { self.comments = NSMutableArray() }
//        self.comments!.addObject(comment)
//        
//        self.saveInBackgroundWithBlock({ (success, error) -> Void in
//            completion(success: success, error: error)
//        })
    }
    
    func getTitle() -> NSString {
        return title.stringByReplacingOccurrencesOfString("\n", withString: "", options: nil, range: nil)
    }
    
    func saveWithCompletion(completion: (success: Bool!, error: NSError!) -> ()) {
//        self.saveInBackgroundWithBlock { (success, error) -> Void in
//            completion(success: success, error: error)
//        }
    }
    
    func destroyWithCompletion(completion: (success: Bool!, error: NSError!) -> ()) {
//        self.deleteInBackgroundWithBlock { (success, error) -> Void in
//            completion(success: success, error: error)
//        }
    }
}
