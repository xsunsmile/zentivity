//
//  EventsViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

<<<<<<< HEAD
class EventsViewController: UIViewController,
BaseTableViewDelegate, NewEventDelegate
{
    
=======
class EventsViewController: UIViewController, BaseTableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate {
>>>>>>> Dynamic filters table
    @IBOutlet weak var tableView: UITableView!
    var baseTable: BaseTableView!
    var datasource: [AnyObject] = []
    let cellId = "EventsTableViewCell"
    let titleId = "EventHeaderTableViewCell"
    let cellHeight = CGFloat(180)
    var hud: JGProgressHUD?
    var refreshControl: UIRefreshControl!
    var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        
        createRefreshControl()

        searchBar = UISearchBar()
        navigationItem.title = "Events"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: UIBarButtonItemStyle.Plain, target: self, action: "presentEventsFilterModal")
        searchBar!.delegate = self
        
        initSubviews()
        refresh(true)
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
    
    func createRefreshControl() {
        refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(
            self,
            action: "refresh:",
            forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func refresh(useHud: Bool) {
        if useHud {
            hud?.textLabel.text = "Loading events..."
            hud?.showInView(self.view, animated: true)
        }
        
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
            
            self.refreshControl.endRefreshing()
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
    
    func didCreateNewEvent(event: Event) {
        self.baseTable.datasource.insert(event, atIndex: 0)
        self.tableView.reloadData()
    }
    
    @IBAction func onAddEventPress(sender: ShadowButton) {
//        var addEventVC = storyboard?.instantiateViewControllerWithIdentifier("NewEventViewController") as NewEventViewController
//        var navVC = UINavigationController(rootViewController: addEventVC)
//        navVC.navigationBar.topItem?.title = "New Event"
//        self.presentViewController(navVC, animated: true, completion: nil)
        performSegueWithIdentifier("createEvent", sender: self)
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewEventDetailSegue" {
            var vc = segue.destinationViewController as EventDetailViewController
            var data = baseTable.datasource as [Event]
            var index = tableView.indexPathForSelectedRow()?.row
            
            vc.event = data[index!]
        } else if segue.identifier == "createEvent" {
            var vc = segue.destinationViewController as NewEventViewController
            vc.delegate = self
        }
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        resignSearchBarFirstResponder()
    }

    func resignSearchBarFirstResponder() {
        if searchBar!.isFirstResponder() {
            searchBar!.resignFirstResponder()
        }
    }
    
    func presentEventsFilterModal() {
        // Present
//        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
//        let navBarHeight = navigationController!.navigationBar.frame.size.height
//        var yOrigin = statusBarHeight + navBarHeight + modalMargin
//        
//        var filterViewFrame = CGRectMake(modalMargin, yOrigin , self.view.frame.width - 2 * modalMargin, self.view.frame.height - statusBarHeight - navBarHeight - 2 * modalMargin)
//        var filterView = UIView(frame: filterViewFrame)
//        
        let filterViewController = storyboard?.instantiateViewControllerWithIdentifier("FilterNavViewController") as UINavigationController
        
        self.presentViewController(filterViewController, animated: true, completion: nil)
//
//        self.addChildViewController(filterViewController)
//        filterViewController.view.frame = filterView.bounds
//        filterView.addSubview(filterViewController.view)
//        filterViewController.didMoveToParentViewController(self)
//        self.view.addSubview(filterView)
    }
}
