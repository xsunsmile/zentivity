//
//  EventDetailViewController.swift
//  zentivity
//
//  Created by Andrew Wen on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate
{
    
    var event: Event!

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var imageShadowView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var eventHeaderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var usersGridView: UICollectionView!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    var contentViewOriginFrame: CGRect!
    var detailHeaderViewOriginFrame: CGRect!
    var dragStartingPoint: CGPoint!
    var detailsIsOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        animateHeaderViewDown()
    }
    
    func initSubviews() {
        let leftConstraint = NSLayoutConstraint(
            item: contentView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0)
        
        let rightConstraint = NSLayoutConstraint(
            item: contentView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0)
        
        view.addConstraint(leftConstraint)
        view.addConstraint(rightConstraint)
        
        usersGridView.delegate = self
        usersGridView.dataSource = self
        
        contentViewOriginFrame = contentView.frame
        detailHeaderViewOriginFrame = eventHeaderView.frame
        
        let gradient = CAGradientLayer()
        let arrayColors = [
            UIColor(rgba: "#211F20").CGColor,
            UIColor.clearColor().CGColor
        ]
        
        imageShadowView.backgroundColor = UIColor.clearColor()
        gradient.frame = imageShadowView.bounds
        gradient.frame.size.width = view.frame.width
        gradient.colors = arrayColors
        imageShadowView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func refresh() {
        if event == nil {
            return
        }
        
        titleLabel.text = event.title
        var dateString = NSMutableAttributedString(
            string: event.startTimeWithFormat("EEEE"),
            attributes: NSDictionary(
                object: UIFont.boldSystemFontOfSize(17.0),
                forKey: NSFontAttributeName))
        
       dateString.appendAttributedString(NSAttributedString(
            string: "\n" + event.startTimeWithFormat("MMM d, yyyy"),
            attributes: NSDictionary(
                object: UIFont(name: "Arial", size: 17.0)!,
                forKey: NSFontAttributeName)))
        
        eventDateLabel.attributedText = dateString
        
        let currentUser = User.currentUser()
        if currentUser != nil {
            joinButton.backgroundColor = joinButtonColor()
            joinButton.setTitle(joinButtonText(), forState: .Normal)
        } else {
            joinButton.setTitle("SignIn", forState: .Normal)
        }
        
        setupBackgroundImageView()
    }
    
    func setupBackgroundImageView() {
        if event.photos?.count > 0 {
            let photo = event.photos![0] as Photo
            photo.fetchIfNeededInBackgroundWithBlock { (photo, error) -> Void in
                let p = photo as Photo
                p.file.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                    println("fetch photo again!!!")
                    if imageData != nil {
                        self.backgroundImageView.image = UIImage(data:imageData)
                    } else {
                        println("Failed to download image data")
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        if User.currentUser() == nil {
            performSegueWithIdentifier("userAuthSegue", sender: self)
        }
        
        User.currentUser().toggleJoinEventWithCompletion(event, completion: { (success, error, state) -> () in
            self.joinButton.backgroundColor = self.joinButtonColor()
            self.joinButton.setTitle(self.joinButtonText(), forState: .Normal)
            self.joinButton.setTitleColor(self.joinButtonTextColor(), forState: .Normal)
            if self.detailsIsOpen {
                self.setHeaderNewColor(self.joinButtonTextColor())
            }
            
            if state == kUserJoinEvent {
                if success != nil {
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
            }
            self.reloadData()
        })
    }
    
    func joinButtonText() -> NSString {
        if event.userJoined(User.currentUser()) {
            return "Cancel"
        } else {
            return "Join"
        }
    }
    
    func joinButtonColor() -> UIColor {
        if detailsIsOpen {
            return UIColor.whiteColor()
        } else {
            if event.userJoined(User.currentUser()) {
                return UIColor(rgba: "#3366cc")
            } else {
                return UIColor(rgba: "#dd4b39")
            }
        }
    }
    
    func joinButtonTextColor() -> UIColor {
        if !detailsIsOpen {
            return UIColor.whiteColor()
        } else {
            if event.userJoined(User.currentUser()) {
                return UIColor(rgba: "#3366cc")
            } else {
                return UIColor(rgba: "#dd4b39")
            }
        }
    }
    
    func reloadData() {
        usersGridView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if event == nil {
            return 0
        }
        return event.confirmedUsers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserGridViewCell", forIndexPath: indexPath) as UserIconCollectionViewCell
        cell.user = event.confirmedUsers[indexPath.row] as? User
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if(kind == UICollectionElementKindSectionHeader) {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "eventUserTypes", forIndexPath: indexPath) as LabelCollectionReusableView
            return cell
        } else {
            return UICollectionReusableView()
        }
    }
    
    @IBAction func onQuit(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onDetailViewDrag(sender: UIPanGestureRecognizer) {
        let velocity = sender.velocityInView(view)
        let point = sender.translationInView(view)
        
        var direction = "up"
        detailsIsOpen = true
        if velocity.y > 0 {
            direction = "down"
            detailsIsOpen = false
        }
        
        if sender.state == .Began {
            animateHeaderColorChanges(direction)
            dragStartingPoint = CGPoint(x: point.x, y: point.y)
        } else if sender.state == .Changed {
            contentView.transform = CGAffineTransformTranslate(contentView.transform, 0,
                (point.y - dragStartingPoint.y)/100)
            backgroundImageView.transform = CGAffineTransformTranslate(backgroundImageView.transform, 0,
                (point.y - dragStartingPoint.y)/50)
        } else if sender.state == .Ended {
            if direction == "up" {
                animateHeaderViewUp()
            } else {
                animateHeaderViewDown()
            }
        }
    }
    
    func animateHeaderViewDown() {
        UIView.animateWithDuration(0.7, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: nil, animations: { () -> Void in
            let dy = self.view.frame.size.height - self.detailHeaderViewOriginFrame.size.height - self.contentViewOriginFrame.origin.y
            self.contentView.transform = CGAffineTransformMakeTranslation(0, dy)
            self.backgroundImageView.transform = CGAffineTransformIdentity
            }) { (completed) -> Void in
                if completed {
                }
        }
    }
    
    func animateHeaderViewUp() {
        UIView.animateWithDuration(0.7, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: nil, animations: { () -> Void in
            let dy = self.contentView.frame.size.height - (self.view.frame.size.height - self.detailHeaderViewOriginFrame.origin.y)
            self.contentView.transform = CGAffineTransformMakeTranslation(0, dy)
            self.backgroundImageView.transform = CGAffineTransformMakeTranslation(0, dy/2)
            }) { (completed) -> Void in
                if completed {
                }
        }
    }
    
    func animateHeaderColorChanges(direction: NSString) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            if direction == "up" {
                self.joinButton.backgroundColor = UIColor.whiteColor()
                self.joinButton.setTitleColor(self.joinButtonTextColor(), forState: .Normal)

                self.setHeaderNewColor(self.joinButtonTextColor())
            } else {
                self.joinButton.backgroundColor = self.joinButtonColor()
                self.joinButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)

                self.setHeaderOriginColor()
            }
        })
    }
    
    func setHeaderOriginColor() {
        self.eventHeaderView.backgroundColor = UIColor.whiteColor()
        
        self.titleLabel.textColor = UIColor.blackColor()
        self.addressLabel.textColor = UIColor(rgba: "#7f7f7f")
        self.phoneLabel.textColor = UIColor(rgba: "#7f7f7f")
    }
    
    func setHeaderNewColor(color: UIColor!) {
        self.eventHeaderView.backgroundColor = color
        
        self.titleLabel.textColor = UIColor.whiteColor()
        self.addressLabel.textColor = UIColor.whiteColor()
        self.phoneLabel.textColor = UIColor.whiteColor()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
