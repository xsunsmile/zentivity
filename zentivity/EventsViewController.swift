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
    var searchButton: UIButton?
    var searchIsOn = false
    var originalTableYPos = CGFloat(0)
    
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
        searchBar = UISearchBar()
        let delta = view.frame.size.width
        searchBar?.frame = CGRectOffset(searchBar!.frame, delta, 0)
//        searchBar?.hidden = true
//        navigationController?.navigationBar.lt_setBackgroundColor(UIColor(rgba: "#fafafa"))
        
        navigationItem.titleView = searchBar
        
        searchBar!.barTintColor = UIColor.groupTableViewBackgroundColor() // UIColor(rgba: "#fafafa")
        searchBar!.placeholder = "Search activities..."
//        searchBar!.searchBarStyle = UISearchBarStyle.Prominent
        searchBar!.showsCancelButton = false
        //        searchBar.showsScopeBar = true
        searchBar!.delegate = self
        
        let searchBarPlaceImage = UIImage(named: "search")
        let frame = CGRectMake(0, 0, 18, 18)
        searchButton = UIButton(frame: frame)
        searchButton!.setBackgroundImage(searchBarPlaceImage, forState: UIControlState.Normal)
        searchButton!.addTarget(self, action: "toggleSearchBar", forControlEvents: UIControlEvents.TouchDown)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchButton!)
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
//                println("add to table offset: \(offsetY)")
//                tableView.frame.size.height = originalTableHeight + offsetY
            }
        } else {
//            println("reset table height to \(originalTableHeight)")
//            tableView.frame.size.height = originalTableHeight // + 44 + menuView.frame.height
            setNavigationBarTransformProgress(0)
            navigationController?.navigationBar.backIndicatorImage = UIImage()
            navigationController?.navigationBar.lt_reset()
        }
    }
    
    func setNavigationBarTransformProgress(progress: CGFloat) {
        println("current progress: \(-44*progress)")
        navigationController?.navigationBar.lt_setTranslationY(-44 * progress)
        navigationController?.navigationBar.lt_setContentAlpha(1-progress)
        
        menuView.transform = CGAffineTransformMakeTranslation(0, -44 * progress)
        tableView.transform = CGAffineTransformMakeTranslation(0, -44 * progress)
        tableView.frame.size.height = view.frame.height - tableView.frame.origin.y
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
    
    func toggleSearchBar() {
        var delta = view.frame.size.width
        
        if (!searchIsOn) {
            delta *= -1;
            searchIsOn = true
//            searchBar?.hidden = false
//            searchBar?.resignFirstResponder()
        } else {
            searchIsOn = false
//            searchBar?.hidden = true
        }

        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
            self.searchBar!.frame = CGRectOffset(self.searchBar!.frame, delta, 0)
//            self.searchButton!.frame = CGRectOffset(self.searchButton!.frame, -delta, 0)
        }) { (completed) -> Void in
        }
        
//        let viewWidth = self.view.frame.width
//        
//        if searchIsOn {
//            self.searchBar?.hidden = true
//            UIView.animateWithDuration(0.4,
//                delay: 0,
//                options: nil, //(.CurveEaseOut | .AllowUserInteraction),
//                animations: { () -> Void in
//                self.searchBar?.transform = CGAffineTransformMakeScale(0.0001, 1)
//                let orignPosX = viewWidth - 10 - self.searchButton!.frame.size.width
//                self.searchButton!.frame.origin.x = orignPosX
//                }) { (completed) -> Void in
//                    self.searchIsOn = false
//            }
//        } else {
//            UIView.animateWithDuration(0.4,
//                delay: 0,
//                options: nil, //(.CurveEaseIn | .AllowUserInteraction),
//                animations: { () -> Void in
//                self.searchButton!.frame.origin.x = 10
//                self.searchBar?.transform = CGAffineTransformIdentity
//                }) { (completed) -> Void in
//                    self.searchIsOn = true
//                    self.searchBar?.hidden = false
//            }
//        }
    }
}
