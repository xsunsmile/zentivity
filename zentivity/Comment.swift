////
////  Comment.swift
////  zentivity
////
////  Created by Eric Huang on 3/7/15.
////  Copyright (c) 2015 Zendesk. All rights reserved.
////

class Comment : PFObject, PFSubclassing {
    @NSManaged var user: PFUser
    @NSManaged var text: String
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
            println("INITING COMMENT")
        }
    }
    
    class func parseClassName() -> String {
        return "Comment"
    }
}