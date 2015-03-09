//
//  EventsViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var baseTable: BaseTableView!
    
    let datasource: [NSDictionary] = []
    let cellId = "EventsTableViewCell"
    let cellHeight = CGFloat(250)

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubviews()
        
        refresh()
    }
    
    func initSubviews() {
        baseTable = BaseTableView(datasource: datasource, cellIdentifier: cellId)
        baseTable.cellHeight = cellHeight
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func refresh() {
        baseTable.datasource = [
            ["title": "Clean tenderlion", "image": "activity1", "date": "2015-10-23"],
            ["title": "Cass' Kitchen Volunteer", "image": "activity2", "date": "2015-02-09"],
            ["title": "2014 Xmas Gifts Exchange", "image": "activity3", "date": "2014-12-23"]
        ]
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
