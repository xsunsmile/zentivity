//
//  EventsViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController,
                            BaseTableViewDelegate,
                            NewEventDelegate,
                            UIScrollViewDelegate,
                            UISearchBarDelegate
{
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var baseTable: BaseTableView!
    var datasource: [AnyObject] = []
    let cellId = "EventsTableViewCell"
    let titleId = "EventHeaderTableViewCell"
    let cellHeight = CGFloat(180)
    let menuTitles = ["New", "Owned", "Going"]
    var rightBarButtonItem: UIBarButtonItem!
    
    var hud: JGProgressHUD?
    var refreshControl: UIRefreshControl!
    var searchBar: UISearchBar?
    var segmentedMenu: HMSegmentedControl?
    var filters = Dictionary<String, String>()
    var searchBarJustResigned: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        
        createRefreshControl()

        rightBarButtonItem = UIBarButtonItem(title: "Filter", style: UIBarButtonItemStyle.Plain, target: self, action: "presentEventsFilterModal")
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        searchBar = UISearchBar()
        navigationItem.titleView = searchBar
        searchBar!.delegate = self
        
        initSubviews()
        refresh(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initSubviews() {
        segmentedMenu = HMSegmentedControl(sectionTitles: menuTitles)
        
        segmentedMenu?.frame = CGRectMake(0, 0, view.frame.width, menuView.frame.height-2)
        segmentedMenu?.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        
        segmentedMenu?.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        segmentedMenu?.font = UIFont.boldSystemFontOfSize(14)
        segmentedMenu?.backgroundColor = UIColor(rgba: "#fafafa")
        segmentedMenu?.selectedTextColor = UIColor(rgba: "#34b5e5")
        segmentedMenu?.textColor = UIColor(rgba: "#33373b")
        
        segmentedMenu?.addTarget(self, action: "onMenuSwitch:", forControlEvents: UIControlEvents.ValueChanged)
        menuView.addSubview(segmentedMenu!)
        
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
        
        Event.listWithOptionsAndCompletion(filters) { (events, error) -> () in
            if events != nil {
                self.datasource = events!
                self.baseTable.datasource = self.datasource
                self.tableView.reloadData()
            } else {
                println("failed to list all events")
                self.showEmptyListView()
            }
            
            self.hud?.dismiss()
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
        performSegueWithIdentifier("createEvent", sender: self)
    }
    
    func onMenuSwitch(control: HMSegmentedControl) {
        blurSearchBar()
        let title = menuTitles[control.selectedSegmentIndex]
        println("selected \(title)")
        let currentUser = User.currentUser() as User
        
        switch(control.selectedSegmentIndex) {
        case 1:
            hud?.showInView(self.view, animated: true)
            currentUser.eventsWithCompletion("admin", completion: { (events, error) -> () in
                if error == nil {
                    self.hud?.dismiss()
                    self.baseTable.datasource = events
                    self.tableView.reloadData()
                } else {
                    println("failed to list up admin events: \(error)")
                }
            })
            break
        case 2:
            hud?.showInView(self.view, animated: true)
            currentUser.eventsWithCompletion("confirmedUsers", completion: { (events, error) -> () in
                if error == nil {
                    self.hud?.dismiss()
                    self.baseTable.datasource = events
                    self.tableView.reloadData()
                } else {
                    println("failed to list up confirmedUsers events: \(error)")
                }
            })
            break
        default:
            refresh(true)
        }
        
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
    
    func presentEventsFilterModal() {
        let filterNVC = storyboard?.instantiateViewControllerWithIdentifier("FilterNavViewController") as UINavigationController
        self.presentViewController(filterNVC, animated: true, completion: nil)

    }
    
    // MARK: - Scroll View
    func tableViewWillBeginDragging(scrollView: UIScrollView) {
        blurSearchBar()
    }
    
    // MARK: - Search Bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        focusSearchBar()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        blurSearchBar()
    }
    
    func focusSearchBar() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func blurSearchBar() {
        searchBar?.resignFirstResponder()
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if countElements(searchBar.text) > 0 {
            filters["title"] = searchBar.text
        }
        
        searchBar.resignFirstResponder()
        refresh(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchBar.isFirstResponder() && countElements(searchBar.text) == 0 {
            if searchBarJustResigned == true {
                searchBarJustResigned = false
            } else {
                filters = Dictionary<String, String>()
                refresh(true)
                searchBar.resignFirstResponder()
            }
            searchBar.resignFirstResponder()
        } else if searchBar.isFirstResponder() && countElements(searchBar.text) == 0 {
            searchBar.resignFirstResponder()
            searchBarJustResigned = true
        }
    }
}
