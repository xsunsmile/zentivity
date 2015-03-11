//
//  EventTableViewCell.swift
//  zentivity
//
//  Created by Hao Sun on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class EventTableViewCell: BaseTableViewCell {
    @IBOutlet weak var eventNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func onDataSet(data: AnyObject!) {
        refresh()
    }
    
    override func refresh() {
        let d = data as Event
        eventNameLabel.text = d.title
    }

}
