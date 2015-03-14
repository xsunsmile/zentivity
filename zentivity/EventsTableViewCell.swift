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
    @IBOutlet weak var joinNowBackgroundView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    
    let dateFormatter = NSDateFormatter()
    var eventImage: UIImage?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        initSubviews()
        refresh()
    }
    
    func initSubviews() {
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
        
        ImageUtils.makeRoundCornerWithBorder(joinNowBackgroundView, borderColor: UIColor.whiteColor().CGColor, borderWidth: 3.0)
        
        if User.currentUser() == nil {
            
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func onDataSet(data: AnyObject!) {
        refresh()
    }

    @IBAction func onJoin(sender: AnyObject) {
        toggleJoin()
    }
    
    func toggleJoin() {
        let event = data as Event
        User.currentUser().toggleJoinEventWithCompletion(event, completion: { (success, error, state) -> () in
            if state == kUserJoinEvent {
                if success != nil {
                    self.joinButton.setTitle("Cancel", forState: UIControlState.Normal)
                    UIAlertView(
                        title: "Great!",
                        message: "See you at the event :)",
                        delegate: self,
                        cancelButtonTitle: "OK"
                        ).show()
                } else {
                    UIAlertView(
                        title: "Error",
                        message: "Unable to join event.",
                        delegate: self,
                        cancelButtonTitle: "Well damn..."
                        ).show()
                }
            } else {
                self.joinButton.setTitle("Join Now", forState: UIControlState.Normal)
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
