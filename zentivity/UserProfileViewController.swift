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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initSubviews() {
        let currentUser = User.currentUser()
        println(currentUser)
        
        currentUser.eventsWithCompletion("confirmedUsers") { (events, error) -> Void in
            if error == nil {
                let events = events as [Event]
                self.initEventsTableView(events)
            }
        }
    }
    
    func initEventsTableView(datasource: [AnyObject]) {
        let cellId = "eventTableCell"
        let baseTable = BaseTableView(datasource: datasource, cellIdentifier: cellId)
        baseTable.cellHeight = CGFloat(100)
        baseTable.controller = self
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
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
