//
//  EventsTableViewCell.swift
//  zentivity
//
//  Created by Andrew Wen on 3/5/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
protocol EventsTableViewCellDelegate: class {
    func editEvent(event: Event)
}

var kEditEventNotification = "kEditEventNotification"

class EventsTableViewCell: BaseTableViewCell {
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventBackgroundImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    let dateFormatter = NSDateFormatter()
    var colors = ["#31b639", "#ffcf00", "#c61800", "1851ce"]
    var appliedGradient = false
    weak var delegate: EventsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        initSubviews()
    }
    
    func initSubviews() {
        if GoogleClient.sharedInstance.alreadyLogin() {
            if let currentUser = User.currentUser() {
                // Blue border for button
                let borderWidth = CGFloat(1.0)
                let borderColor = UIColor(rgba: "#A2D6E6").CGColor
                joinView.layer.borderColor = borderColor
                joinView.layer.borderWidth = borderWidth
            }
        } else {
            joinButton.hidden = true
        }
        
        addBottomShadow()
    }
    
    func addBottomShadow() {
        contentView.layer.shadowColor = UIColor.blackColor().CGColor
        contentView.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
        contentView.layer.shadowOpacity = 0.7
        contentView.layer.shadowRadius = 0.5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func onDataSet(data: AnyObject!) {
        refresh()
    }

    @IBAction func onJoinTapped(sender: AnyObject) {
        let event = data as Event
        
        if let currentUser = User.currentUser() {
            if event.ownedByUser(currentUser) {
                delegate?.editEvent(event)
                NSNotificationCenter.defaultCenter().postNotificationName(kEditEventNotification, object: nil, userInfo: ["event": event])
            } else {
                toggleJoin()
            }
        }
    }
    
    func toggleJoin() {
        if joinButton.titleLabel!.text == "Cancel" {
            joinButton.setTitle("Join", forState: .Normal)
        } else {
            joinButton.setTitle("Cancel", forState: .Normal)
        }
        
        let event = data as Event
        User.currentUser().toggleJoinEventWithCompletion(event, completion: { (success, error, state) -> () in
            if state == kUserJoinEvent {
                if success != nil {
                    self.joinButton.setTitle("Cancel", forState: .Normal)
                }
            } else {
                self.joinButton.setTitle("Join", forState: .Normal)
            }
        })
    }

    override func refresh() {
        if data == nil {
            return
        }
        
        let event = data as Event
       
        eventNameLabel.text = event.getTitle()
        eventDateLabel.text = event.startTimeWithFormat("EEEE MMM d, HH:mm")
        
        if event.photos?.count > 0 {
            var thumbnail = event.thumbnail
            thumbnail.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    self.eventBackgroundImageView.image = UIImage(data: data)
                } else {
                    self.eventBackgroundImageView.image = UIImage(named: "noActivity")
                }
            })
        } else {
            eventBackgroundImageView.image = UIImage(named: "noActivity")
        }
        
        if event.locationString != nil {
            locationLabel.text = event.locationString
        } else {
            locationLabel.text = "1019 Market Street, San Francisco, CA 94103"
        }
        
        if event.ownedByUser(User.currentUser()) {
            joinButton.setTitle("Edit", forState: .Normal)
        } else if event.userJoined(User.currentUser()) {
            joinButton.setTitle("Cancel", forState: .Normal)
        } else {
            joinButton.setTitle("Join", forState: .Normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventBackgroundImageView.image = nil
    }
}
