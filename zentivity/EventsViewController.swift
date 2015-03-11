//
//  EventsViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController,
                            BaseTableViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    var baseTable: BaseTableView!
    
    var datasource: [AnyObject] = []
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
        baseTable.delegate = self
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func refresh() {
        Event.listWithCompletion { (events, error) -> () in
            if events != nil {
                self.datasource = events!
                self.baseTable.datasource = self.datasource
                self.tableView.reloadData()
            } else {
                println("failed to list events")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cellDidSelected(tableView: UITableView, indexPath: NSIndexPath) {
        println("cell is selected \(indexPath.row)")
        performSegueWithIdentifier("viewEventDetailSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewEventDetailSegue" {
            let vc = segue.destinationViewController as UIViewController
        }
    }
}
