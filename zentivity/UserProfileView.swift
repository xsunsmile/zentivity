//
//  UserProfileView.swift
//  zentivity
//
//  Created by Andrew Wen on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class UserProfileView: UIView {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var yourEventsTable: UITableView!
    @IBOutlet weak var participatingEventsTable: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        profileImageView.layer.cornerRadius = 4
        profileImageView.clipsToBounds = true
        
        addEventButton.layer.cornerRadius = 4
        addEventButton.clipsToBounds = true
    }

    @IBAction func onAddEvent(sender: AnyObject) {
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
