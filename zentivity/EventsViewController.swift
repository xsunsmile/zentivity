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
                            UISearchBarDelegate,
                            EmptyTableViewDelegate,
                            SearchFilterViewDelegate,
                            UIViewControllerTransitioningDelegate
{
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let cellId = "EventsTableViewCell"
    let titleId = "EventHeaderTableViewCell"
    let cellHeight = CGFloat(150)
    let menuTitles = ["New", "Attending", "Hosting"]
//    let viewTransitionDelegate = TransitionDelegate()
    
    var baseTable: BaseTableView!
    var datasource: [AnyObject] = []
    var rightBarButtonItem: UIBarButtonItem!
    var hud: JGProgressHUD?
    var refreshControl: UIRefreshControl!
    var searchBarView: SearchFilterView!
    var segmentedMenu: HMSegmentedControl?
    var filters = Dictionary<String, String>()
    var searchBarJustResigned: Bool = false
    var searchButton: UIButton?
    var searchIsOn = false
    var originalTableYPos = CGFloat(0)
    var titleView: UIView!
//    var titleLabel: UILabel!
    var bannerImage: UIImageView!
    var closeSearchButton: UIButton!
    var emptyTableView: EmptyTableView!
    var currentSearchString = ""
    
    let presentationAnimator = TransitionPresentationAnimator()
    let dismissalAnimator = TransitionDismissalAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "editEvent:", name: kEditEventNotification, object: nil)
        
        createRefreshControl()
        initSubviews()
        refresh(true)
    }
    
    func swipeGesture(gesture: UIPanGestureRecognizer) {
        println("hide bar pan detected")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        originalTableYPos = tableView.frame.origin.y
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.lt_reset()
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
        
//        titleLabel = UILabel(frame: titleView!.frame)
//        titleLabel.text = "Zentivity"
//        
//        titleView!.addSubview(titleLabel)
        
        bannerImage = UIImageView(image: UIImage(named: "zentivity-logo-banner"))
        bannerImage.contentMode = UIViewContentMode.Bottom
//        bannerImage.bounds = bannerImage.frame
//        bannerImage.clipsToBounds = true
        bannerImage.frame = titleView.frame
        titleView.addSubview(bannerImage)
        
        searchBarView = SearchFilterView(frame: titleView!.frame)
        searchBarView.delegate = self

        searchBarView.searchBar!.placeholder = "Search activities..."
        searchBarView.searchBar!.showsCancelButton = false
        searchBarView.searchBar!.delegate = self
        
        navigationItem.titleView = titleView
        navigationController?.navigationBar.backIndicatorImage = UIImage()
    }
    
    func initSubviews() {
        initNavBar()
        
        emptyTableView = EmptyTableView(frame: CGRectMake(0, view.frame.height/2, view.frame.width, 70))
        emptyTableView.message = "There are no data now"
        emptyTableView.buttonLabel = "Create a new event"
        emptyTableView.delegate = self
        
        segmentedMenu = HMSegmentedControl(sectionTitles: menuTitles)
        
        segmentedMenu?.frame = CGRectMake(0, 0, view.frame.width, menuView.frame.height-2)
        segmentedMenu?.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        
        segmentedMenu?.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        segmentedMenu?.selectionIndicatorHeight = CGFloat(2)
        segmentedMenu?.segmentEdgeInset = UIEdgeInsetsMake(0, 2, 0, 2)
        segmentedMenu?.font = UIFont.boldSystemFontOfSize(14)
        segmentedMenu?.backgroundColor = UIColor(white: 1, alpha: 0.2)
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
        println("refresh tab: \(currentSearchString)")
        if currentSearchString.isEmpty {
            refreshLatestEventsList(useHud)
        } else if currentSearchString == "admin" {
            refreshAdminEventsList(useHud)
        } else if currentSearchString == "join" {
            refreshJoinEventsList(useHud)
        }
    }
    
    func refreshJoinEventsList(useHud: Bool) {
        if let currentUser = User.currentUser() {
            if useHud {
                hud?.textLabel.text = "Loading events..."
                hud?.showInView(self.view, animated: true)
            }
            
            currentUser.eventsWithCompletion("confirmedUsers", completion: { (events, error) -> () in
                self.hud?.dismiss()
                self.refreshControl.endRefreshing()
                
                if error == nil {
                    if events.count > 0 {
                        let filterdEvents = NSMutableArray()
                        for e in events {
                            if !e.ownedByUser(currentUser) {
                                filterdEvents.addObject(e)
                            }
                        }
                        
                        if filterdEvents.count > 0 {
                            self.baseTable.datasource = filterdEvents
                            self.tableView.reloadData()
                        } else {
                            self.showEmptyListView("You have not join any event yet", label: "Find an event")
                        }
                    } else {
                        self.showEmptyListView("You have not join any event yet", label: "Find an event")
                    }
                } else {
                    println("failed to list up confirmedUsers events: \(error)")
                    self.showEmptyListView("Seems like you do not have interenet connection.", label: "refresh")
                }
            })
        }
    }
    
    func refreshAdminEventsList(useHud: Bool) {
        println("refresh admin...")
        if let currentUser = User.currentUser() {
            if useHud {
                hud?.textLabel.text = "Loading events..."
                hud?.showInView(self.view, animated: true)
            }

            currentUser.eventsWithCompletion("admin", completion: { (events, error) -> () in
                self.hud?.dismiss()
                self.refreshControl.endRefreshing()
                
                if error == nil {
                    if events.count > 0 {
                        self.baseTable.datasource = events
                        self.tableView.reloadData()
                    } else {
                        self.showEmptyListView("You do not host any event yet.", label: "Create a new event")
                    }
                } else {
                    println("failed to list up admin events: \(error)")
                    self.showEmptyListView("Seems like you do not have interenet connection.", label: "refresh")
                }
            })
        } else {
            println("did not refresh admin, current user not good")
        }
    }
    
    func refreshLatestEventsList(useHud: Bool) {
        if useHud {
            hud?.textLabel.text = "Loading events..."
            hud?.showInView(self.view, animated: true)
        }
        
        Event.listWithOptionsAndCompletion(filters) { (events, error) -> () in
            self.hud?.dismiss()
            self.refreshControl.endRefreshing()
            
            if error == nil {
                if events!.count > 0 {
                    self.removeEmptyListView()
                    
                    let filterdEvents = NSMutableArray()
                    
                    if let currentUser = User.currentUser() {
                        for e in events! {
                            if !e.ownedByUser(currentUser) && !e.userJoined(currentUser) {
                                filterdEvents.addObject(e)
                            }
                        }
                    } else {
                        for e in events! {
                            filterdEvents.addObject(e)
                        }
                    }
                    
                    self.datasource = filterdEvents
                    self.baseTable.datasource = self.datasource
                    self.tableView.reloadData()
                } else {
                    self.showEmptyListView("There is no new events yet.", label: "refresh")
                }
            } else {
                println("failed to list all events")
                self.showEmptyListView("Seems like you do not have interenet connection.", label: "refresh")
            }
        }
    }
    
    func showEmptyListView(message: NSString?, label: NSString?) {
        tableView.hidden = true
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        if let m = message {
            emptyTableView.message = m
        }
        if let m = label {
            emptyTableView.buttonLabel = m
        }
        view.addSubview(emptyTableView)
    }
    
    func removeEmptyListView() {
        tableView.hidden = false
        self.view.backgroundColor = UIColor.whiteColor()
        emptyTableView.removeFromSuperview()
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
        println("added new event refresh...")
        self.baseTable.datasource.insert(event, atIndex: 0)
        refresh(true)
    }
    
    func didDeleteEvent(event: Event) {
        println("deleted event refresh...")
        var i = 0
        for e in self.baseTable.datasource {
            let e = e as Event
            if e.objectId == event.objectId {
                self.baseTable.datasource.removeAtIndex(i)
            }
            i += 1
        }
        refresh(true)
    }
    
    func onMenuSwitch(control: HMSegmentedControl) {
        let title = menuTitles[control.selectedSegmentIndex]

        self.removeEmptyListView()
        switch(control.selectedSegmentIndex) {
        case 2:
            currentSearchString = "admin"
            if GoogleClient.sharedInstance.alreadyLogin() {
                if let currentUser = User.currentUser() {
                    refreshAdminEventsList(true)
                }
            } else {
                refreshAdminEventsList(false)
                presentAuthModal()
            }
        case 1:
            currentSearchString = "join"
            if GoogleClient.sharedInstance.alreadyLogin() {
                if let currentUser = User.currentUser() {
                    refreshJoinEventsList(true)
                }
            } else {
                refreshJoinEventsList(false)
                presentAuthModal()
            }
        default:
            currentSearchString = ""
            refreshLatestEventsList(true)
        }
    }
    
    func presentAuthModal() {
        let appVC = storyboard?.instantiateViewControllerWithIdentifier("AppViewController") as AppViewController
        self.presentViewController(appVC, animated: true, completion: nil)
    }
    
    // MARK: - Scroll View
    func tableViewWillBeginDragging(scrollView: UIScrollView) {
        searchBarView.searchBar.resignFirstResponder()
    }
    
    func tableViewDidScroll(scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y;
//        
//        if (offsetY > 0) {
//            if (offsetY >= 44) {
//                setNavigationBarTransformProgress(1)
//            } else {
//                setNavigationBarTransformProgress(CGFloat(offsetY) / CGFloat(44))
//            }
//        } else {
//            setNavigationBarTransformProgress(0)
//            navigationController?.navigationBar.backIndicatorImage = UIImage()
//            navigationController?.navigationBar.lt_reset()
//        }
    }
    
    func setNavigationBarTransformProgress(progress: CGFloat) {
//        navigationController?.navigationBar.lt_setTranslationY(-44 * progress)
//        navigationController?.navigationBar.lt_setContentAlpha(1-progress)
//        
//        menuView.transform = CGAffineTransformMakeTranslation(0, -44 * progress)
//        tableView.transform = CGAffineTransformMakeTranslation(0, -44 * progress)
//        tableView.frame.size.height = view.frame.height - tableView.frame.origin.y
    }
    
    // MARK: - Search Bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBarView.searchBar.resignFirstResponder()
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
                self.searchBarView.removeFromSuperview()
                self.titleView.addSubview(self.bannerImage)
                
                self.searchButton?.setBackgroundImage(UIImage(named: "search"), forState: .Normal)
                self.searchBarView.searchBar.resignFirstResponder()
                self.searchIsOn = false
            } else {
                self.bannerImage.removeFromSuperview()
                self.titleView.addSubview(self.searchBarView)
                
                self.searchButton?.setBackgroundImage(UIImage(named: "cross"), forState: .Normal)
                self.searchBarView.searchBar.becomeFirstResponder()
                self.searchIsOn = true
            }
        }) { (completed) -> Void in
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    func onCTA(action: NSString) {
        switch(action) {
        case "refresh":
            refresh(true)
            break
        case "Find an event":
            currentSearchString = ""
            segmentedMenu?.selectedSegmentIndex = 0
            refresh(true)
            break
        default:
            performSegueWithIdentifier("createEvent", sender: self)
        }
    }
    
    func onSearchFilterPress() {
        performSegueWithIdentifier("showSearchFilter", sender: self)
    }
    
    func editEvent(notification: NSNotification) {
        if navigationController == nil {
            println("navigation controller is missing")
            return
        }
        performSegueWithIdentifier("createEvent", sender: notification.userInfo!["event"])
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        setNavigationBarTransformProgress(0)
        if segue.identifier == "viewEventDetailSegue" {
            var vc = segue.destinationViewController as EventDetailViewController
            var data = baseTable.datasource as [Event]
            var index = tableView.indexPathForSelectedRow()?.row
            
            vc.event = data[index!]
            
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .Custom

            let tapGR = UIPanGestureRecognizer(target: dismissalAnimator, action: "onModalPan:")
            let tapGR2 = UIPanGestureRecognizer(target: dismissalAnimator, action: "onModalPan:")
            tapGR.delegate = vc
            tapGR2.delegate = vc
            vc.modalPanGuesture = tapGR
            vc.modalPanGuesture2 = tapGR2
            dismissalAnimator.modalView = vc
            
//            dismissalAnimator.addPanGesture()
            
//            let animator = ZFModalTransitionAnimator(modalViewController: vc)
//            animator.dragable = true
//            animator.direction = ZFModalTransitonDirection.Bottom
//            self.animator.setContentScrollView:detailViewController.scrollview

//            vc.transitioningDelegate = animator
//            vc.modalPresentationStyle = .Custom
        } else if segue.identifier == "createEvent" {
            var vc = segue.destinationViewController as NewEventViewController
            vc.delegate = self
            if let event = sender as? Event {
                println("send event for edit")
                vc.event = event
            }
//            let destinationViewController = segue.destinationViewController as DetailViewController
//            destinationViewController.imageToDisplay = imageView.image
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissalAnimator
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissalAnimator
    }
}
