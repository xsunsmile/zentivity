//
//  EventDetailView.swift
//  zentivity
//
//  Created by Andrew Wen on 3/7/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
import MapKit

class EventDetailView: UIView {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventPhoneLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var eventLocationMapView: MKMapView!
    @IBOutlet weak var eventAttendeesLabel: UILabel!
    @IBOutlet weak var eventAttendeesTable: UITableView!
    @IBOutlet weak var eventActionButton: UIButton!


    @IBAction func onCall(sender: AnyObject) {
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
