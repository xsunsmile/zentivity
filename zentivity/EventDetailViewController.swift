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
            if event.userJoined(User.currentUser()) {
                joinButton.setTitle("Cancel", forState: UIControlState.Normal)
                joinButton.backgroundColor = UIColor(rgba: "#3366cc")
            } else {
                joinButton.setTitle("Join", forState: UIControlState.Normal)
                joinButton.backgroundColor = UIColor(rgba: "#dd4b39")
            }
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
            if state == kUserJoinEvent {
                if success != nil {
                    self.joinButton.setTitle("Cancel", forState: UIControlState.Normal)
                    self.joinButton.backgroundColor = UIColor(rgba: "#3366cc")
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
                self.joinButton.setTitle("Join", forState: UIControlState.Normal)
                self.joinButton.backgroundColor = UIColor(rgba: "#dd4b39")
            }
            self.reloadData()
        })
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
        println("detected drag")
        let velocity = sender.velocityInView(view)
        
        if velocity.y < 0 {
            animateHeaderViewUp()
        } else {
            animateHeaderViewDown()
        }
    }
    
    func animateHeaderViewDown() {
        UIView.animateWithDuration(0.7, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: nil, animations: { () -> Void in
            let dy = self.view.frame.size.height - self.detailHeaderViewOriginFrame.size.height - self.contentViewOriginFrame.origin.y
            self.contentView.transform = CGAffineTransformMakeTranslation(0, dy)
        }) { (completed) -> Void in
            if completed {
                
            }
        }
    }
    
    func animateHeaderViewUp() {
        UIView.animateWithDuration(0.7, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: nil, animations: { () -> Void in
            let dy = self.contentView.frame.size.height - (self.view.frame.size.height - self.detailHeaderViewOriginFrame.origin.y)
            self.contentView.transform = CGAffineTransformMakeTranslation(0, dy)
            }) { (completed) -> Void in
                if completed {
                    
                }
        }
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
