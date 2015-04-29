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
//    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var eventDateLabel: UILabel!
//    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet weak var joinButton: UIButton!
    
//    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var NumAttendeeLabel: UILabel!
    
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
//                self.joinView.layer.borderColor = borderColor
//                self.joinView.layer.borderWidth = borderWidth
            }
        } else {
//            joinButton.hidden = true
        }
        
        addBottomShadow()
        refresh()
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
        let event = data as! Event
        
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
//        if joinButton.titleLabel!.text == "Cancel" {
//            joinButton.setTitle("Join", forState: .Normal)
//        } else {
//            joinButton.setTitle("Cancel", forState: .Normal)
//        }
        
        let event = data as! Event
        User.currentUser()!.toggleJoinEventWithCompletion(event, completion: { (success, error, state) -> () in
            if state == kUserJoinEvent {
                if success != nil {
//                    self.joinButton.setTitle("Cancel", forState: .Normal)
                }
            } else {
//                self.joinButton.setTitle("Join", forState: .Normal)
            }
        })
    }

    override func refresh() {
        if data == nil {
            return
        }
        
        let event = data as! Event
        
//        refreshDistance()
       
        eventNameLabel.text = event.getTitle() as String
        eventDateLabel.text = event.startTimeWithFormat("EEEE MMM d, hh:mm a") as String
        
        NumAttendeeLabel.text = "\(event.confirmedUsers.count)"
        let duration = event.endTime.timeIntervalSinceDate(event.startTime)
        let hours = Int(round(duration/3600))
        if hours == 1 {
            durationLabel.text = "\(hours) hour"
        } else {
            durationLabel.text = "\(hours) hours"
        }
        
//        distanceLabel.text = "2mi"
        
        if event.photos?.count > 0 {
            var thumbnail = event.thumbnail
            thumbnail.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
                    self.eventBackgroundImageView.image = UIImage(data: data!)
                } else {
                    self.eventBackgroundImageView.image = UIImage(named: "noActivity")
                }
            })
        } else {
            eventBackgroundImageView.image = UIImage(named: "noActivity")
        }
        
        if event.locationString != nil {
//            locationLabel.text = event.locationString
        } else {
//            locationLabel.text = "1019 Market Street, San Francisco, CA 94103"
        }
        
//        joinButton.setTitle(joinButtonTitle(), forState: .Normal)
        
        if event.ownedByUser(User.currentUser()) {
            leftExpansion.fillOnTrigger = true
            leftExpansion.threshold = 2.5
            leftExpansion.buttonIndex = 0
            
            let editView = MGSwipeButton(title: "Edit", backgroundColor: UIColor.grayColor(), insets: UIEdgeInsetsMake(30, 15, 30, 15)) { (cell) -> Bool in
                let cell = cell as! EventsTableViewCell
                let me = cell.controller as? EventsViewController
                let indexPath = me!.tableView.indexPathForCell(cell)
                me!.performSegueWithIdentifier("createEvent", sender: event)
                cell.hideSwipeAnimated(false)
                return false
            }
            
            leftButtons = [ editView ]
            leftSwipeSettings.transition = MGSwipeTransition.TransitionBorder
            
            let deleteView = MGSwipeButton(title: "Delete", backgroundColor: UIColor(rgba: "#3366cc"), insets: UIEdgeInsetsMake(30, 15, 30, 15)) { (cell) -> Bool in
                let cell = cell as! EventsTableViewCell
                let me = cell.controller as? EventsViewController
                let indexPath = me!.tableView.indexPathForCell(cell)
                
                event.destroyWithCompletion({ (success, error) -> () in
                    if error != nil {
                        println("Failed to delete event")
                    }
                })
                
                me!.baseTable.datasource.removeAtIndex(indexPath!.row)
                me!.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Left)
                
                if me!.baseTable.datasource.count == 0 {
                    me!.showEmptyListView("You are not organizing any events yet.", label: "Create a new event")
                }
                return false
            }
            
            rightButtons = [ deleteView ]
            rightSwipeSettings.transition = MGSwipeTransition.TransitionBorder
        } else if !event.userJoined(User.currentUser()) {
            leftExpansion.fillOnTrigger = true
            leftExpansion.threshold = 2.5
            leftExpansion.buttonIndex = 0
            
            let joinView = MGSwipeButton(title: joinButtonTitle() as String, backgroundColor: joinButtonColor(), insets: UIEdgeInsetsMake(30, 15, 30, 15)) { (cell) -> Bool in
                let cell = cell as! EventsTableViewCell
                let me = cell.controller as? EventsViewController
                let indexPath = me!.tableView.indexPathForCell(cell)
                if event.ownedByUser(User.currentUser()) {
                    println("should edit event")
                    me!.performSegueWithIdentifier("createEvent", sender: event)
                    //                me!.refresh(false)
                    cell.hideSwipeAnimated(false)
                } else {
                    cell.toggleJoin()
                    me!.baseTable.datasource.removeAtIndex(indexPath!.row)
                    me!.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Right)
                }
                return false
            }
            
            rightButtons = []
            leftButtons = [ joinView ]
            leftSwipeSettings.transition = MGSwipeTransition.TransitionBorder
        } else {
            let cancelView = MGSwipeButton(title: joinButtonTitle() as String, backgroundColor: joinButtonColor(), insets: UIEdgeInsetsMake(30, 15, 30, 15)) { (cell) -> Bool in
                let cell = cell as! EventsTableViewCell
                let me = cell.controller as? EventsViewController
                let indexPath = me!.tableView.indexPathForCell(cell)
                cell.toggleJoin()
                me!.baseTable.datasource.removeAtIndex(indexPath!.row)
                me!.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Left)
                
                if me!.baseTable.datasource.count == 0 {
                    me!.showEmptyListView("You have not joined any events yet.", label: "Find an event")
                }
                return false
            }
            
            leftButtons = []
            rightButtons = [ cancelView ]
            rightSwipeSettings.transition = MGSwipeTransition.TransitionBorder
        }
    }
    
    func refreshDistance() {
        let event = data as! Event
        let zendeskLoc = CLLocation(latitude: 37.782193, longitude: -122.410254)
        
        var address = "1019 Market Street, San Francisco, CA"
        if event.locationString != nil {
            address = event.locationString!
        }
        
        println("event location is \(address)")
        LocationUtils.sharedInstance.getGeocodeFromAddress(address, completion: { (places, error) -> () in
            if error == nil {
                let places = places as! [CLPlacemark]
                let target = places.last
                let currentLocation = CLLocation(latitude: target!.location.coordinate.latitude, longitude: target!.location.coordinate.longitude)
                let rawDistance = 1000*zendeskLoc.distanceFromLocation(currentLocation)/(1609.344*1000)
                println("raw dist: \(rawDistance)")
                
                if rawDistance < 1 {
//                    self.distanceLabel.text = NSString(format: "%.1f mi", rawDistance)
                } else {
//                    self.distanceLabel.text = NSString(format: "%d mi", Int(rawDistance))
                }
            } else {
                println("Failed to get places for address \(error)")
            }
        })
    }
    
    func joinButtonTitle() -> NSString {
        let event = data as! Event
        if event.ownedByUser(User.currentUser()) {
            return "Edit"
        } else if event.userJoined(User.currentUser()) {
            return "Cancel"
        } else {
            return "Join"
        }
    }
    
    func joinButtonColor() -> UIColor {
        let event = data as! Event
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
