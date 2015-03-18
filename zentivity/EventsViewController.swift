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
    let titleId = "EventHeaderTableViewCell"
    let cellHeight = CGFloat(180)
    var hud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        
        var searchBar = UISearchBar()
        navigationItem.titleView = searchBar
        initSubviews()
        refresh()
    }
    
    func initSubviews() {
        baseTable = BaseTableView(datasource: datasource, cellIdentifier: cellId)
        baseTable.cellHeight = cellHeight
        baseTable.titleIdentifier = titleId
        baseTable.delegate = self
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.registerNib(UINib(nibName: titleId, bundle: nil), forHeaderFooterViewReuseIdentifier: titleId)
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func refresh() {
        hud?.textLabel.text = "Loading events..."
        hud?.showInView(self.view, animated: true)
        Event.listWithCompletion { (events, error) -> () in
            if events != nil {
                self.datasource = events!
                self.baseTable.datasource = self.datasource
                self.tableView.reloadData()
                self.hud?.dismiss()
            } else {
                println("failed to list events")
                self.hud?.dismiss()
                self.showEmptyListView()
            }
        }
    }
    
    func showEmptyListView() {
        tableView.hidden = true
        let errorView = UIView()
        errorView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(errorView)
        self.view.backgroundColor = UIColor.grayColor()
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
        var addEventVC = storyboard?.instantiateViewControllerWithIdentifier("AddEventViewController") as AddEventViewController
        var navVC = UINavigationController(rootViewController: addEventVC)
        navVC.navigationBar.topItem?.title = "New Event"
        self.presentViewController(navVC, animated: true, completion: nil)
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
