//
//  NewEventViewController.swift
//  zentivity
//
//  Created by Andrew Wen on 3/14/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class NewEventViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var dateFormatter = NSDateFormatter()
    var isEditingStartDate = false
    var isEditingEndDate = false
    
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

    var photos: [UIImage] = []
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var photosCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        setup()
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
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 { return 6 }
        else if section == 1 || section == 2 { return 1 }
        else { return 0 }
    }
    
    @IBAction func startDateCellTapped(sender: UITapGestureRecognizer) {
        var state = true
        
        if isEditingStartDate { state = false }
        
        view.endEditing(true)
        isEditingStartDate = state
        isEditingEndDate = false
        eventTable.beginUpdates()
        eventTable.reloadData()
        eventTable.endUpdates()
    }
    
    @IBAction func endDateCellTapped(sender: UITapGestureRecognizer) {
        var state = true
        
        if isEditingEndDate { state = false }
        
        view.endEditing(true)
        isEditingStartDate = false
        isEditingEndDate = state
        eventTable.beginUpdates()
        eventTable.reloadData()
        eventTable.endUpdates()
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
        descriptionField.becomeFirstResponder()
    }
    
    @IBAction func onTableTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func onCreate(sender: UIBarButtonItem) {
        var event = Event()
        event.title = titleField.text
        event.locationString = addressField.text
//        event.contactNumber = PFUser.currentUser().contactNumber
        event.descript = descriptionField.text
        event.admin = PFUser.currentUser()
        event.startTime = startTimePicker.date
        event.endTime = endTimePicker.date
        event.photos = Photo.photosFromImages(photos)
        
        // Set invitedUsernames to set invited relationship!
//        event.invitedUsernames = ["awen", "ehuang", "hsun"]
        
        event.createWithCompletion { (success, error) -> () in
            if success == true {
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
    
    
    /*  PHOTO COLLECTION */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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

}
