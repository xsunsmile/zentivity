//
//  UserProfileViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController,
                                 BaseTableViewDelegate
{

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileOrganization: UILabel!
    @IBOutlet weak var profileContactInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var baseTable: BaseTableView!
    
    let datasource: [AnyObject] = []
    let cellId = "EventTableViewCell"
    let cellHeight = CGFloat(100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initSubviews() {
        baseTable = BaseTableView(datasource: datasource, cellIdentifier: cellId)
        baseTable.cellHeight = cellHeight
        baseTable.delegate = self
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func refresh() {
        let currentUser = User.currentUser()
        println(currentUser)
        currentUser.eventsWithCompletion("admin", completion: { (events, error) -> () in
            if error == nil && events.count > 0 {
                self.baseTable.datasource = events
                self.tableView.reloadData()
            } else {
                println("failed to list up events: \(error)")
            }
        })
        
        //        if currentUser.name.length > 0 {
        //            profileName.text = currentUser.name
        //        }
        //        if currentUser.profileImage.length > 0 {
        //            println("downloading profileimage: \(currentUser.profileImage)")
        //            profileImageView.setImageWithURL(NSURL(string: currentUser.profileImage)!)
        //        }
        profileContactInfo.text = currentUser.username
    }
    
    func cellDidSelected(tableView: UITableView, indexPath: NSIndexPath) {
        performSegueWithIdentifier("viewEventDetailSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewEventDetailSegue" {
            var vc = segue.destinationViewController as EventDetailViewController
            var data = baseTable.datasource as [Event]
            var index = tableView.indexPathForSelectedRow()?.row
            
            vc.event = data[index!]
        }
    }
}
