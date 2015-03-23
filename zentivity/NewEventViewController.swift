//
//  NewEventViewController.swift
//  zentivity
//
//  Created by Andrew Wen on 3/14/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

protocol NewEventDelegate: class {
    func didCreateNewEvent(event: Event)
}

class NewEventViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FriendPickerVCDelegate {
    
    var dateFormatter = NSDateFormatter()
    var isEditingStartDate = false
    var isEditingEndDate = false
    var event: Event?
    
    weak var delegate: NewEventDelegate?
    
    @IBOutlet var eventTable: UITableView!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimePickerCell: UITableViewCell!
    @IBOutlet weak var endTimePickerCell: UITableViewCell!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    var invited: [User] = []
    var invitedUsernames = NSMutableArray()

    @IBOutlet weak var invitedCollection: UICollectionView!
    var photos: [UIImage] = []
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var photosCollection: UICollectionView!
    
    var friendPickerVC: FriendPickerVC!
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        setup()

        friendPickerVC = storyboard?.instantiateViewControllerWithIdentifier("FriendPickerVC") as FriendPickerVC
        friendPickerVC.delegate = self
        invitedCollection.delegate = self
        invitedCollection.dataSource = self
    }
    
    func setup() {
        dateFormatter.dateFormat = "MMM d, yyyy @ hh:mm a"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
//        eventTable.rowHeight = UITableViewAutomaticDimension
//        
//        startTimePickerCell.clipsToBounds = true
//        endTimePickerCell.clipsToBounds = true
        
//        startTimePickerCell.bounds = CGRect(x: startTimePickerCell.center.x, y:
//            startTimePickerCell.center.y, width: startTimePickerCell.bounds.width, height: 0)
//        endTimePickerCell.bounds = CGRect(x: endTimePickerCell.center.x, y: endTimePickerCell.center.y, width: endTimePickerCell.bounds.width, height: 0)
        
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary

        if event != nil {
            hydrateView()
            return
        }

        updateDateLabelWithDate(startTimeLabel, date: startTimePicker.date)
        endTimePicker.setDate(startTimePicker.date.dateByAddingTimeInterval(60*60*1), animated: false)
        updateDateLabelWithDate(endTimeLabel, date: endTimePicker.date)
    }

    func hydrateView() {
        navigationItem.title = "Edit event"
        createButton.title = "Save"
        
        titleField.text = event?.title
        addressField.text = event?.locationString
        
        let startTime = event?.startTime
        let endTime = event?.endTime
        startTimePicker.setDate(startTime!, animated: true)
        endTimePicker.setDate(endTime!, animated: true)
        startTimeLabel.text = dateFormatter.stringFromDate(startTime!)
        endTimeLabel.text = dateFormatter.stringFromDate(endTime!)
        descriptionField.text = event?.descript
        descriptionLabel.hidden = true
        
//        photos = event?.photos as [UIImage]
//        invitedUsernames = NSMutableArray(array: (event?.invitedUsernames)!)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        var cell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        
//        if cell.tag == 4 {
//            return isEditingStartDate == true ? 162 : 0
//        } else if cell.tag == 6 {
//            return isEditingEndDate == true ? 162 : 0
//        } else {
//            return 44
//        }
        var height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                return isEditingStartDate == true ? 162 : 0
            } else if indexPath.row == 5 {
                return isEditingEndDate == true ? 162 : 0
            } else {
                return height
            }
        } else {
            return height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 { return 6 }
        else if section == 1 || section == 2 { return 1 }
        else if section == 3 { return 2 }
        else { return 0 }
    }
    
    @IBAction func startDateCellTapped(sender: UITapGestureRecognizer) {
        var state = true
        
        if isEditingStartDate { state = false }
        else if startTimeLabel.text == "--" {
            updateDateLabelWithDate(startTimeLabel, date: startTimePicker.date)
        }
        
        view.endEditing(true)
        isEditingStartDate = state
        isEditingEndDate = false

        updateTable()
    }
    
    @IBAction func endDateCellTapped(sender: UITapGestureRecognizer) {
        var state = true
        
        if isEditingEndDate { state = false }
        else if startTimeLabel.text == "--" {
            updateDateLabelWithDate(endTimeLabel, date: endTimePicker.date)
        }
        
        view.endEditing(true)
        isEditingStartDate = false
        isEditingEndDate = state

        updateTable()
    }

    func updateTable() {
        eventTable.beginUpdates()
        eventTable.reloadData()
        eventTable.endUpdates()
    }

    func hideAllDatePickers() {
        isEditingStartDate = false
        isEditingEndDate = false
        updateTable()
    }
    
    @IBAction func onStartDateChanged(sender: UIDatePicker) {
        updateDateLabelWithDate(startTimeLabel, date: sender.date)
    }
    
    @IBAction func onEndDateChanged(sender: UIDatePicker) {
        updateDateLabelWithDate(endTimeLabel, date: sender.date)
    }
    
    func updateDateLabelWithDate(label: UILabel, date: NSDate) {
        let date = dateFormatter.stringFromDate(date)
        label.text = "\(date)"
    }
    
    @IBAction func onDescriptionFieldTapped(sender: UITapGestureRecognizer) {
        descriptionLabel.hidden = true
        hideAllDatePickers()
        descriptionField.becomeFirstResponder()
    }
    
    @IBAction func onTableTapped(sender: AnyObject) {
        view.endEditing(true)
        hideAllDatePickers()
    }
    
    @IBAction func onCreate(sender: UIBarButtonItem) {
        var event: Event!
        
        if self.event != nil { event = self.event }
        else { event = Event() }
        
        event.title = titleField.text
        event.locationString = addressField.text
//        event.contactNumber = PFUser.currentUser().contactNumber
        event.descript = descriptionField.text
        event.admin = PFUser.currentUser()
        event.startTime = startTimePicker.date
        event.endTime = endTimePicker.date
        event.photos = Photo.photosFromImages(photos)
        let invUsernames = invitedUsernames as [AnyObject] as [String]
        event.invitedUsernames = invUsernames
        
        event.createWithCompletion { (success, error) -> () in
            if success == true {
                self.delegate?.didCreateNewEvent(event)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                UIAlertView(
                    title: "Error",
                    message: "Failed to create this event.",
                    delegate: self,
                    cancelButtonTitle: "Well damn..."
                    ).show()
            }
        }
    }
    
    /* COLLECTION */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photosCollection {
            return photos.count + 1
        } else {
            println("invited numofitemsinsection")
            return invited.count
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == photosCollection {
            var cell: UICollectionViewCell
            
            if indexPath.row < photos.count {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as UICollectionViewCell
                var imageView = UIImageView(image: photos[indexPath.row])
                imageView.frame.size = CGSize(width: 45, height: 45)
                cell.addSubview(imageView)
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.lightGrayColor().CGColor
            } else {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("addActionCell", forIndexPath: indexPath) as UICollectionViewCell
            }
            
            cell.layer.cornerRadius = 3
            cell.clipsToBounds = true
            
            return cell
        } else {
            
            println("cell for invited")
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserGridViewCell", forIndexPath: indexPath) as UserIconCollectionViewCell
            cell.user = invited[indexPath.row]
            return cell
        }

    }
    
    @IBAction func onAddPhotoCellTapped(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.photos.append(image)
        self.photosCollection.reloadData()
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func handleAddFriendsButtonPressed(sender: UIButton) {
        var friendPickerNVC = UINavigationController(rootViewController: friendPickerVC)
        self.presentViewController(friendPickerNVC, animated: true, completion: nil)
    }
    
    func friendPickerDidSelectUsers(friendPickerVC: FriendPickerVC, users: [User]) {
        invited = users
        invitedUsernames = NSMutableArray()
        
        for user in invited {
            let user = user as User
            invitedUsernames.addObject(user.username)
        }
        
        invitedCollection.reloadData()
    }
}
