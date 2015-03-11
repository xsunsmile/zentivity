//
//  UserProfileViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

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
        baseTable.controller = self
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func refresh() {
        let currentUser = User.currentUser()
        println(currentUser)
        //        currentUser.eventsWithCompletion("confirmedUsers", completion: { (events, error) -> () in
        //            if error == nil && events.count > 0 {
        //                let events = events as [Event]
        //                self.initEventsTableView(events as [Event])
        //                self.tableView.reloadData()
        //            }
        //        })
        Event.listWithCompletion { (events, error) -> () in
            if events != nil {
                self.baseTable.datasource = events!
                self.tableView.reloadData()
            } else {
                println("failed to list events")
            }
        }
        
        if currentUser.name.length > 0 {
            profileName.text = currentUser.name
        }
        if currentUser.profileImage.length > 0 {
            profileImageView.setImageWithURL(NSURL(string: currentUser.profileImage)!)
        }
        profileContactInfo.text = currentUser.username
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
