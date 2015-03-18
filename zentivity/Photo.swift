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
    
    // Use for creating only!!
    // Sets each photo's user to to current user
    class func photosFromImages(images: [UIImage]) -> NSMutableArray {
        var photos = NSMutableArray()

        for image in images {
            var photo = Photo()
            photo.file = PFFile(name:"image.png", data: UIImagePNGRepresentation(image))
            photo.user = User.currentUser()
            photos.addObject(photo as Photo)
        }
        
        return photos
    }
}