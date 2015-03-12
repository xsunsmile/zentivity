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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var usersGridView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        joinButton.layer.cornerRadius = 4
        joinButton.clipsToBounds = true
        
        titleLabel.text = event.title
        usersGridView.delegate = self
        usersGridView.dataSource = self
        
        if event.userJoined(User.currentUser()) {
            joinButton.setTitle("I will quit", forState: UIControlState.Normal)
        } else {
            joinButton.setTitle("I want to participate!", forState: UIControlState.Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        toggleJoinEvent()
    }
    
    func toggleJoinEvent() {
        if event.userJoined(User.currentUser()) {
            quitEvent()
            joinButton.setTitle("I want to participate!", forState: UIControlState.Normal)
        } else {
            joinEvent()
            joinButton.setTitle("I will quit", forState: UIControlState.Normal)
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
    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return event.confirmedUsers.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell = attendeesTable.dequeueReusableCellWithIdentifier("attendeeCell") as UserTableViewCell
//        let confirmedUser = event.confirmedUsers[indexPath.row] as User
//        confirmedUser.fetchIfNeededInBackgroundWithBlock { (user, error) -> Void in
//            if error == nil {
//                let u = user as User
//                println("got user: \(u)")
//                if u.name.length > 0 {
//                    cell.nameLabel.text = u.name
//                } else {
//                    cell.nameLabel.text = u.username
//                }
//            }
//        }
//        
//        return cell
//    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
