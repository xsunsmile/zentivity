////
////  Photo.swift
////  zentivity
////
////  Created by Eric Huang on 3/7/15.
////  Copyright (c) 2015 Zendesk. All rights reserved.
////

class Photo : PFObject, PFSubclassing {
    @NSManaged var user: PFUser
    @NSManaged var file: PFFile
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String! {
        return "Photo"
    }
}