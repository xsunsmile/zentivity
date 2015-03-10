//
//  BaseTableViewCell.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var data: AnyObject? {
        didSet {
            onDataSet(data!)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func onDataSet(data: AnyObject!) {
        println("You should implement this in subclass")
    }
    
    func refresh() {
        println("You should implement this in subclass")
    }
}
