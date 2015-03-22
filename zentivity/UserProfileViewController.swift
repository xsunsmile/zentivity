//
//  UserProfileViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController,
                                 BaseTableViewDelegate
{

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileContactInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var baseTable: BaseTableView!
    let cellId = "MenuTableViewCell"
    let cellHeight = CGFloat(50)
    let datasource = [
        ["icon": "map", "title": "Test"],
        ["icon": "map", "title": "Test"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if User.currentUser() == nil {
            return
        }
 
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        initSubviews()
        refresh()
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
        if let currentUser = User.currentUser() {
            let currentUser = currentUser as User
            if let name = currentUser.name as? String {
                if countElements(name) > 0 {
                    profileName.text = name
                }
            }
            
            if currentUser.imageUrl?.length > 0 {
                profileImageView.setImageWithURL(NSURL(string: currentUser.imageUrl!)!)
            }
            
            self.profileContactInfo.text = currentUser.username
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func cellDidSelected(tableView: UITableView, indexPath: NSIndexPath) {
//       performSegueWithIdentifier("viewEventDetailSegue", sender: self)
    }
    
    @IBAction func onUserLogout(sender: UIButton) {
        User.logoutWithCompletion { (completed) -> Void in
            println("User logout: \(completed)")
        }
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
