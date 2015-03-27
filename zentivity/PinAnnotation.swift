//
//  PinAnnotation.swift
//  zentivity
//
//  Created by Hao Sun on 3/27/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotation : NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    var title: String = ""
    var subtitle: String = ""
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}