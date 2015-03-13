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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var usersGridView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
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
        
        ImageUtils.makeRoundImageWithBorder(joinButton, borderColor: UIColor(rgba: "#EFEFF4").CGColor)
        
        titleLabel.text = event.title
        
        usersGridView.delegate = self
        usersGridView.dataSource = self
        
        if event.userJoined(User.currentUser()) {
            joinButton.setTitle("Quit", forState: UIControlState.Normal)
        } else {
            joinButton.setTitle("Join", forState: UIControlState.Normal)
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
        toggleJoinEvent()
    }
    
    func toggleJoinEvent() {
        if event.userJoined(User.currentUser()) {
            quitEvent()
            joinButton.setTitle("Join", forState: UIControlState.Normal)
        } else {
            joinEvent()
            joinButton.setTitle("Quit", forState: UIControlState.Normal)
        }
    }
    
    func joinEvent() {
        User.currentUser().confirmEvent(event, completion: { (success, error) -> () in
            if success == true {
                UIAlertView(
                    title: "Great!",
                    message: "See you at the event :)",
                    delegate: self,
                    cancelButtonTitle: "OK"
                    ).show()
                self.reloadData()
            } else {
                UIAlertView(
                    title: "Error",
                    message: "Unable to join event.",
                    delegate: self,
                    cancelButtonTitle: "Well damn..."
                    ).show()
            }
        })
    }
    
    func quitEvent() {
        UIAlertView(
            title: "Confirm",
            message: "Are you sure?",
            delegate: self,
            cancelButtonTitle: "OK"
            ).show()
        User.currentUser().declineEvent(event, completion: { (success, error) -> () in
            if success == true {
                self.reloadData()
            } else {
                UIAlertView(
                    title: "Error",
                    message: "Unable to join event.",
                    delegate: self,
                    cancelButtonTitle: "Well damn..."
                    ).show()
            }
        })       
    }
    
    func reloadData() {
        usersGridView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
