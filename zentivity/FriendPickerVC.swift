//
//  FriendPickerVC.swift
//  zentivity
//
//  Created by Eric Huang on 3/22/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

protocol FriendPickerVCDelegate: class {
    func friendPickerDidSelectUsers(friendPickerVC: FriendPickerVC, users: [User])
}

class FriendPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, TURecipientsBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var turBar: TURecipientsBar!
    
    var data: NSMutableArray = []
    var filteredData: NSMutableArray = []
    var selected: NSMutableArray = []
    var searchTerm: String? = "" { didSet { filterData() } }
    let highlightedAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSBackgroundColorAttributeName: UIColor(red: 19/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1.0), NSUnderlineStyleAttributeName: 1]
    
    weak var delegate: FriendPickerVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredData = data
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 51.0
        turBar.showsAddButton = false
        turBar.recipientsBarDelegate = self
        
        fetchUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUsers() {
        User.allWithCompletion { (users, success) -> Void in
            if success == true {
                if let users = users {
                    for user in users {
                        self.data.addObject(user as User)
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    func filterData() {
        if let searchTerm = searchTerm {
            if searchTerm != "" {
                filteredData = []
                for user in data {
                    let user = user as User
//                    if let userName = user.name {
                        if (user.name.lowercaseString.rangeOfString(searchTerm.lowercaseString) != nil) {
                            self.filteredData.addObject(user)
                        }
//                    }
                }
            } else {
                filteredData = data
            }
        } else {
            filteredData = data
        }
        tableView.reloadData()
    }
    
    func recipientsBar(recipientsBar: TURecipientsBar!, textDidChange searchText: String!) {
        searchTerm = searchText
    }
    
    func recipientsBar(recipientsBar: TURecipientsBar!, didSelectRecipient recipient: TURecipientProtocol!) {
        clearSearchTerm()
    }
    
    func recipientsBar(recipientsBar: TURecipientsBar!, didRemoveRecipient objectId: String!) {
        for user in selected {
            let user = user as User
            if user.objectId == objectId {
                selected.removeObject(user)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendPickerCell") as FriendPickerCell
        cell.user = filteredData[indexPath.row] as? User
        cell.selectionStatus = selected.containsObject(cell.user!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as FriendPickerCell
        let user = cell.user! as User
        if selected.containsObject(user) {
            selected.removeObject(user)
            for recipient in turBar.recipients {
                let recipient = recipient as TURecipient
                if recipient.address as? String == user.objectId {
                    turBar.removeRecipient(recipient)
                }
            }
            cell.selectionStatus = false
        } else {
            selected.addObject(user)
            turBar.addRecipient(TURecipient.recipientWithTitle(user.name, address: user.objectId) as TURecipient)
            cell.selectionStatus = true
        }
        clearSearchTerm()
    }
    
    func clearSearchTerm() {
        searchTerm = ""
        turBar.text = ""
    }
    
    
    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = delegate {
            delegate.friendPickerDidSelectUsers(self, users: selected as NSArray as [User])
        }
//        delegate?.friendPickerDidSelectEmails(self, users: selected)
//        var emails = NSMutableArray()
//        for user in selected {
//            let user = user as User
//            emails.addObject(user.username)
//        }
//        
//        if let delegate = delegate {
//            delegate.friendPickerDidSelectEmails(self, emails: emails)
//        }
    }
    
    @IBAction func onCancelButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
