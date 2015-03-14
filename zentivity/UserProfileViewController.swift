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
        
        if currentUser.name.length > 0 {
            profileName.text = currentUser.name
        }
        if currentUser.imageUrl.length > 0 {
            profileImageView.setImageWithURL(NSURL(string: currentUser.imageUrl)!)
        }
        if currentUser.aboutMe.length > 0 {
            profileOrganization.text = currentUser.aboutMe
        }
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
