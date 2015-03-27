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
var kJoinEventNotification = "kJoinEventNotification"

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
//    weak var delegate: EventsTableViewCellDelegate?

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
                self.joinView.layer.borderColor = borderColor
                self.joinView.layer.borderWidth = borderWidth
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
//                delegate?.editEvent(event)
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
        
        joinButton.setTitle(joinButtonTitle(), forState: .Normal)
        
        leftExpansion.fillOnTrigger = true
        leftExpansion.threshold = 2
        leftExpansion.buttonIndex = 0
        
        //configure left buttons
        let joinView = MGSwipeButton(title: joinButtonTitle(), backgroundColor: joinButtonColor(), insets: UIEdgeInsetsMake(30, 15, 30, 15)) { (cell) -> Bool in
            let cell = cell as EventsTableViewCell
            let me = cell.controller as? EventsViewController
            let indexPath = me!.tableView.indexPathForCell(cell)
            if event.ownedByUser(User.currentUser()) {
                println("should edit event")
                self.leftExpansion.fillOnTrigger = false
                me!.performSegueWithIdentifier("createEvent", sender: event)
                cell.hideSwipeAnimated(false)
            } else {
                cell.toggleJoin()
                me!.baseTable.datasource.removeAtIndex(indexPath!.row)
                me!.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Right)
            }
            return false
        }
        
        // MGSwipeButton(title: joinButtonTitle(), backgroundColor: joinButtonColor(), padding: 10)
        leftButtons = [ joinView ]
        leftSwipeSettings.transition = MGSwipeTransition.TransitionBorder
    }
    
    func joinButtonTitle() -> NSString {
        let event = data as Event
        if event.ownedByUser(User.currentUser()) {
            return "Edit"
        } else if event.userJoined(User.currentUser()) {
            return "Cancel"
        } else {
            return "Join"
        }
    }
    
    func joinButtonColor() -> UIColor {
        let event = data as Event
        if event.ownedByUser(User.currentUser()) {
            return UIColor.grayColor()
        } else {
            if event.userJoined(User.currentUser()) {
                return UIColor(rgba: "#3366cc")
            } else {
                return UIColor(rgba: "#dd4b39")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventBackgroundImageView.image = nil
    }
}
