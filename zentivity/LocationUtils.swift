//
//  LocationUtils.swift
//  zentivity
//
//  Created by Hao Sun on 3/15/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class LocationUtils: NSObject {

    var geoCoder = CLGeocoder()
    
    class var sharedInstance: LocationUtils {
        struct Static {
            static let instance = LocationUtils()
        }

        return Static.instance
    }
    
    func getPlacemarkFromLocationWithCompletion(location: CLLocation, completion: (places: [AnyObject]?, error: NSError?) -> ()){
        geoCoder.reverseGeocodeLocation(location, completion)
    }
    
    func getGeocodeFromAddress(address: NSString, completion: (places: [AnyObject]!, error: NSError!) -> ()) {
        geoCoder.geocodeAddressString(address, completion)
    }

}
