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
    let dateFormatter = NSDateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func onDataSet(data: AnyObject!) {
        refresh()
    }

    @IBAction func onJoin(sender: AnyObject) {
        let event = data as Event
        User.currentUser().confirmEvent(event, completion: { (success, error) -> Void in
            if error == nil {
                println("user joined event")
            } else {
                println("user can not join event \(error)")
            }
        })
    }

    override func refresh() {
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let event = data as Event

        eventNameLabel.text = event.title
        eventDateLabel.text = dateFormatter.stringFromDate(event.startTime)

        if event.photos?.count > 0 {
            let photo = event.photos![0] as Photo
            photo.fetchIfNeededInBackgroundWithBlock { (photo, error) -> Void in
                let p = photo as Photo
                p.file.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                    if imageData != nil {
                        self.eventBackgroundImageView.image = UIImage(data:imageData)
                    } else {
                        println("Failed to download image data")
                    }
                })
            }
        } else {
            eventBackgroundImageView.image = UIImage(named: "activity1")
        }

    }
}
