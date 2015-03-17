//
//  EventHeaderTableViewCell.swift
//  zentivity
//
//  Created by Hao Sun on 3/16/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class EventHeaderTableViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.frame = bounds
    }
}
