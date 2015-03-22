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
    let cellHeight = CGFloat(120)
    let menuTitles = ["New", "Hosting", "Attending"]
    var rightBarButtonItem: UIBarButtonItem!
    
    var hud: JGProgressHUD?
    var refreshControl: UIRefreshControl!
    var searchBar: UISearchBar?
    var segmentedMenu: HMSegmentedControl?
    var filters = Dictionary<String, String>()
    var searchBarJustResigned: Bool = false
    var searchButton: UIButton?
    var searchIsOn = false
    var originalTableYPos = CGFloat(0)
    var titleView: UIView!
    var titleLabel: UILabel!
    var closeSearchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        
        createRefreshControl()
        initSubviews()
        refresh(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        originalTableYPos = tableView.frame.origin.y
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.lt_reset()
    }
    
    func initNavBar() {
        let searchBarPlaceImage = UIImage(named: "search")
        let frame = CGRectMake(0, 0, 18, 18)
        searchButton = UIButton(frame: frame)
        searchButton!.setBackgroundImage(searchBarPlaceImage, forState: UIControlState.Normal)
        searchButton!.addTarget(self, action: "toggleSearchBar", forControlEvents: UIControlEvents.TouchDown)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton!)
        
        let closeFrame = CGRectMake(0, 0, 14, 14)
        closeSearchButton = UIButton(frame: closeFrame)
        closeSearchButton.setBackgroundImage(searchBarPlaceImage, forState: .Normal)
        closeSearchButton.addTarget(self, action: "toggleSearchBar", forControlEvents: .TouchDown)
        
        let titleWidth = view.frame.width - searchButton!.frame.width - 60
        titleView = UIView(frame: CGRect(x: 0, y: 0, width: titleWidth, height: 33))
        titleView.backgroundColor = UIColor.clearColor()
        
        titleLabel = UILabel(frame: titleView!.frame)
        titleLabel.text = "Zentivity"
        
        titleView!.addSubview(titleLabel)
        
        searchBar = UISearchBar(frame: titleView!.frame)
        searchBar!.backgroundImage = UIImage()
        searchBar!.barTintColor = UIColor.clearColor()
        searchBar!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        searchBar!.setTranslatesAutoresizingMaskIntoConstraints(true)
        
//        titleView!.addSubview(searchBar!)
        
        navigationItem.titleView = titleView
        
//        searchBar!.barTintColor = UIColor.groupTableViewBackgroundColor() // UIColor(rgba: "#fafafa")
        searchBar!.placeholder = "Search activities..."
//        searchBar!.searchBarStyle = UISearchBarStyle.Prominent
        searchBar!.showsCancelButton = false
        //        searchBar.showsScopeBar = true
        searchBar!.delegate = self
    }
    
    func initSubviews() {
        initNavBar()
        
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
    
        switch(control.selectedSegmentIndex) {
        case 1:
            if let currentUser = User.currentUser() {
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
            } else {
                presentAuthModal()
            }
        case 2:
            if let currentUser = User.currentUser() {
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
            } else {
                presentAuthModal()
            }
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
    
    func presentAuthModal() {
        let appVC = storyboard?.instantiateViewControllerWithIdentifier("AppViewController") as AppViewController
        self.presentViewController(appVC, animated: true, completion: nil)
    }
    
    func presentEventsFilterModal() {
//        let filterNVC = storyboard?.instantiateViewControllerWithIdentifier("FilterNavViewController") as UINavigationController
//        self.presentViewController(filterNVC, animated: true, completion: nil)
    }
    
    // MARK: - Scroll View
    func tableViewWillBeginDragging(scrollView: UIScrollView) {
//        blurSearchBar()
//        originalTableHeight = tableView.frame.height
    }
    
    func tableViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y;
        if (offsetY > 0) {
            if (offsetY >= 44) {
                setNavigationBarTransformProgress(1)
            } else {
                setNavigationBarTransformProgress(CGFloat(offsetY) / CGFloat(44))
            }
        } else {
            setNavigationBarTransformProgress(0)
            navigationController?.navigationBar.backIndicatorImage = UIImage()
            navigationController?.navigationBar.lt_reset()
        }
    }
    
    func setNavigationBarTransformProgress(progress: CGFloat) {
        navigationController?.navigationBar.lt_setTranslationY(-44 * progress)
        navigationController?.navigationBar.lt_setContentAlpha(1-progress)
        
        menuView.transform = CGAffineTransformMakeTranslation(0, -44 * progress)
        tableView.transform = CGAffineTransformMakeTranslation(0, -44 * progress)
        tableView.frame.size.height = view.frame.height - tableView.frame.origin.y
    }
    
    // MARK: - Search Bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        focusSearchBar()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
//        blurSearchBar()
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
    
    func toggleSearchBar() {
        UIView.transitionWithView(titleView, duration: 0.7, options: .TransitionCrossDissolve, animations: { () -> Void in
            if self.searchIsOn {
                self.searchBar!.removeFromSuperview()
                self.titleView.addSubview(self.titleLabel)
                
                self.searchButton?.setBackgroundImage(UIImage(named: "search"), forState: .Normal)
                self.searchIsOn = false
            } else {
                self.titleLabel.removeFromSuperview()
                self.titleView.addSubview(self.searchBar!)
                
                self.searchButton?.setBackgroundImage(UIImage(named: "cross"), forState: .Normal)
                self.searchIsOn = true
            }
        }) { (completed) -> Void in
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
}
