//
//  UserProfileViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

protocol UserProfileViewControllerDelegate: class {
    func closeMenuAndDo(action: NSString)
}

class UserProfileViewController: UIViewController,
                                 BaseTableViewDelegate
{

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileContactInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var baseTable: BaseTableView!
    weak var delegate: UserProfileViewControllerDelegate?
    
    let cellId = "MenuTableViewCell"
    let cellHeight = CGFloat(50)
    var datasource: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if User.currentUser() == nil {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "userLogin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "userLogout", object: nil)
 
        initSubviews()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initSubviews() {
        baseTable = BaseTableView(datasource: datasource, cellIdentifier: cellId)
        baseTable.cellHeight = cellHeight
        baseTable.delegate = self
        
        tableView.dataSource = baseTable
        tableView.delegate = baseTable
        
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1;
        profileImageView.layer.borderColor = UIColor.grayColor().CGColor
        
        backgroundImageView.setImageToBlur(backgroundImageView.image, completionBlock: { () -> Void in
        })
    }
    
    func refresh() {
        println("refresh user profile")
        if GoogleClient.sharedInstance.alreadyLogin() {
            if let currentUser = User.currentUser() {
                let currentUser = currentUser as User
                
                let name = currentUser.objectForKey("name") as String
                if countElements(name) > 0 {
                    profileName.text = name
                }
                
                let imageUrl = currentUser.objectForKey("imageUrl") as String
                if countElements(imageUrl) > 0 {
                    profileImageView.setImageWithURL(NSURL(string: currentUser.imageUrl)!)
                }
                
                self.profileContactInfo.text = currentUser.username
                
                datasource = [
                    ["icon": "ListEvents", "title": "Events", "action": "listNewEvents"],
                    ["icon": "addEvent", "title": "Host an event", "action": "addEvent"],
                    ["icon": "logoutBlack", "title": "Log Out", "action": "logOut"]
                ]
            }
        } else {
            println("Switch menu to login")
            datasource = [
                ["icon": "ListEvents", "title": "Events", "action": "listNewEvents"],
                ["icon": "addEvent", "title": "Host an event", "action": "addEvent"],
                ["icon": "login", "title": "Log In", "action": "logOut"]
            ]
        }
        
        baseTable.datasource = datasource
        tableView.reloadData()
    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        println("Hide status bar on Profile")
        return true
    }
    
    func cellDidSelected(tableView: UITableView, indexPath: NSIndexPath) {
       let action = datasource[indexPath.row]["action"] as NSString
        delegate?.closeMenuAndDo(action)
    }
    
    @IBAction func onUserLogout(sender: UIButton) {
        User.logoutWithCompletion { (completed) -> Void in
            println("User logout: \(completed)")
        }
        
        refresh()
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
