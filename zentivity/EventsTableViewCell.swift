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
    @IBOutlet weak var eventBackgroundImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var joinLabel: UILabel!
//    @IBOutlet weak var dateView: UIView!
//    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    let dateFormatter = NSDateFormatter()
    var colors = ["#31b639", "#ffcf00", "#c61800", "1851ce"]
    var appliedGradient = false

    override func awakeFromNib() {
        super.awakeFromNib()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        initSubviews()
        refresh()
    }
    
    func initSubviews() {
        var color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        
        let cornerRadius = CGFloat(3)
        shadowView.layer.masksToBounds = true
        shadowView.layer.cornerRadius = cornerRadius
        
        contentView.backgroundColor = UIColor.clearColor()
        contentView.layer.shadowColor = UIColor.blackColor().CGColor
//        contentView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 5).CGPath
        contentView.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
        contentView.layer.shadowOpacity = 0.7
        contentView.layer.shadowRadius = 0.5
//        contentView.layer.sh
//        contentView.layer.masksToBounds = true
//        contentView.clipsToBounds = false
        
//        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
//        shadowView.layer.shadowOpacity = 0.7
//        shadowView.layer.shadowOffset = CGSizeMake(-0.5, 0.5)
//        shadowView.layer.shadowRadius = 0.5
        
        let borderWidth = CGFloat(1.0)
        let borderColor = UIColor(rgba: "#efefef").CGColor
//
//        var rightBorder = CALayer()
//        rightBorder.borderColor = borderColor
//        rightBorder.frame = CGRect(x: joinView.frame.size.width - borderWidth, y: 0, width: borderWidth, height: joinView.frame.size.height)
//        rightBorder.borderWidth = borderWidth
//        
        var topBorder = CALayer()
        topBorder.borderColor = borderColor
        topBorder.frame = CGRect(x: 0, y: borderWidth, width: joinView.frame.size.width, height: borderWidth)
        topBorder.borderWidth = borderWidth
        
        joinView.layer.addSublayer(topBorder)
//        joinView.layer.addSublayer(rightBorder)
//        
        joinView.layer.masksToBounds = true
//
//        topBorder = CALayer()
//        topBorder.borderColor = borderColor
//        topBorder.frame = CGRect(x: 0, y: borderWidth, width: dateView.frame.size.width, height: borderWidth)
//        topBorder.borderWidth = borderWidth
//        
//        dateView.layer.addSublayer(topBorder)
//        
//        dateView.layer.masksToBounds = true
        
        let tapGR = UITapGestureRecognizer(target: self, action: "onJoinTap:")
        tapGR.numberOfTapsRequired = 1
        joinView.addGestureRecognizer(tapGR)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func onDataSet(data: AnyObject!) {
        refresh()
    }
    
    func onJoinTap(tapGR: UITapGestureRecognizer) {
        println("Join is tapped")
        toggleJoin()
    }

    func toggleJoin() {
        let event = data as Event
        User.currentUser().toggleJoinEventWithCompletion(event, completion: { (success, error, state) -> () in
            if state == kUserJoinEvent {
                if success != nil {
                    self.joinLabel.text = "Cancel"
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
                self.joinLabel.text = "Join"
            }
        })
    }

    override func refresh() {
        if data == nil {
            return
        }
        
        let event = data as Event
       
        eventNameLabel.text = event.getTitle()
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
            eventBackgroundImageView.image = UIImage(named: "noActivity")
        }
        
        var cati = ""
        for c in event.categories {
            cati += (c as NSString) + " "
        }
//        if !cati.isEmpty { categoryLabel.text = cati }
        
        if !event.descript.isEmpty {
//            descriptionLabel.text = event.descript
        }
        
        if event.locationString != nil {
            locationLabel.text = event.locationString
        } else {
            locationLabel.text = "1019 Market Street, San Francisco, CA 94103"
        }
        
        if event.userJoined(User.currentUser()) {
            joinLabel.text = "Cancel"
        } else {
            joinLabel.text = "Join"
        }
    }
    
    func applyGradient() {
        let gradient = CAGradientLayer()
        let arrayColors = [
            UIColor.clearColor().CGColor,
            UIColor(rgba: "#211F20").CGColor
        ]
        
        gradientView.backgroundColor = UIColor.clearColor()
        gradient.frame = gradientView.bounds
        gradient.colors = arrayColors
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    override func prepareForReuse() {
        eventBackgroundImageView.image = nil
    }
}
