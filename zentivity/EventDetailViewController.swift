//
//  EventDetailViewController.swift
//  zentivity
//
//  Created by Andrew Wen on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController, UITableViewDataSource {
    
    var event: Event!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var attendeesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        joinButton.layer.cornerRadius = 4
        joinButton.clipsToBounds = true
        
        titleLabel.text = event.title
        
        attendeesTable.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        User.currentUser().confirmEvent(event, completion: { (success, error) -> () in
            if success == true {
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
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.confirmedUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = attendeesTable.dequeueReusableCellWithIdentifier("attendeeCell") as UserTableViewCell
        
        cell.nameLabel.text = event.confirmedUsers[indexPath.row].name
        
        return cell
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
