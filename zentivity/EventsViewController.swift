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
    let cellHeight = CGFloat(150)

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
        
        var searchBarHeight = navigationController?.navigationBar.frame.height
        var searchBar = UISearchBar(frame: CGRectMake(0, 0, view.frame.size.width * 0.8, searchBarHeight! * 0.6))
        
//        searchBar.translucent = true
//        searchBar.backgroundColor = UIColor.clearColor()
//        searchBar.delegate = self
        
//        var searchField = searchBar.valueForKey("_searchField") as UITextField
//        searchField.backgroundColor = UIColor.grayColor()
        
//        for subView in searchBar.subviews {
//            for field in subView.subviews {
//                if field.isKindOfClass(UITextField) {
//                    let textField = field as UITextField
//                    textField.backgroundColor = UIColor.grayColor()
//                }
//            }
//        }
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(rgba: "#fafafa")
        
        navigationItem.titleView = searchBar
    }
    
    func refresh() {
        Event.listWithCompletion { (events, error) -> () in
            if events != nil {
                self.datasource = events!
                self.baseTable.datasource = self.datasource
                self.tableView.reloadData()
            } else {
                println("failed to list events")
                self.showEmptyListView()
            }
        }
    }
    
    func showEmptyListView() {
        tableView.hidden = true
    }
    
    @IBAction func onMenuPress(sender: UIBarButtonItem) {
        if User.currentUser() != nil {
            performSegueWithIdentifier("showUserProfileSegue", sender: self)
        } else {
            performSegueWithIdentifier("userAuthSegue", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cellDidSelected(tableView: UITableView, indexPath: NSIndexPath) {
        println("cell is selected \(indexPath.row)")
        performSegueWithIdentifier("viewEventDetailSegue", sender: self)
    }
    
    @IBAction func onAddEventPress(sender: ShadowButton) {
        performSegueWithIdentifier("newEventSegue", sender: self)
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
