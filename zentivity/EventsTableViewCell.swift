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
    @IBOutlet weak var gradientView: UIView!
    
    let dateFormatter = NSDateFormatter()
    var eventImage: UIImage?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradient = CAGradientLayer()
        let arrayColors = [
            UIColor.clearColor().CGColor,
            UIColor(rgba: "#211F20").CGColor
        ]
 
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        gradientView.backgroundColor = UIColor.clearColor()
        gradient.frame = gradientView.bounds
        gradient.colors = arrayColors
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
 
        refresh()
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
        if data == nil {
            return
        }
        
        let event = data as Event
       
        eventNameLabel.text = event.title
        eventDateLabel.text = dateFormatter.stringFromDate(event.startTime)

        if eventImage != nil {
            return
        }
        
        if event.photos?.count > 0 {
            let photo = event.photos![0] as Photo
            photo.fetchIfNeededInBackgroundWithBlock { (photo, error) -> Void in
                let p = photo as Photo
                p.file.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                    println("fetch photo again!!!")
                    if imageData != nil {
                        self.eventBackgroundImageView.image = UIImage(data:imageData)
                        self.eventImage = self.eventBackgroundImageView.image
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
