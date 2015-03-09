//
//  EventsTableViewCell.swift
//  zentivity
//
//  Created by Andrew Wen on 3/5/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class EventsTableViewCell: BaseTableViewCell {
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventBackgroundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func onDataSet(data: NSDictionary) {
        println("onDataSet is called on child")
        refresh()
    }
    
    override func refresh() {
        eventNameLabel.text = data!["title"] as NSString
        eventBackgroundImageView.image = UIImage(named: data!["image"] as NSString)
        eventDateLabel.text = data!["date"] as NSString
    }
}
