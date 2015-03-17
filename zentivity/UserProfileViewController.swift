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
    let cellHeight = CGFloat(40)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if User.currentUser() == nil {
            return
        }
 
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
        baseTable.titleSource = ["Your Projects"]
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        ImageUtils.makeRoundCornerWithBorder(
            profileImageView,
            borderColor: UIColor(rgba: "#3e3e3e").CGColor,
            borderWidth: 1.0
        )
    }
    
    func refresh() {
        var currentUser = User.currentUser() as User
        currentUser.eventsWithCompletion("admin", completion: { (events, error) -> () in
            println(events)
            println(error)
            if error == nil && events.count > 0 {
                
                if currentUser.name != "" {
                    self.profileName.text = currentUser.name
                }
                if currentUser.imageUrl != "" {
                    self.profileImageView.setImageWithURL(NSURL(string: currentUser.imageUrl)!)
                }
                if User.currentUser().name != "" {
                    self.profileOrganization.text = currentUser.aboutMe
                }
                self.profileContactInfo.text = currentUser.username
                
                self.baseTable.datasource = events
                self.tableView.reloadData()
            } else {
                println("failed to list up events: \(error)")
            }
        })
    }
    
    func cellDidSelected(tableView: UITableView, indexPath: NSIndexPath) {
        performSegueWithIdentifier("viewEventDetailSegue", sender: self)
    }
    
    @IBAction func onSignOut(sender: UIBarButtonItem) {
        User.logOut()
        User.logoutWithCompletion { (completed) -> Void in
            println("logout user: \(completed)")
        }
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
