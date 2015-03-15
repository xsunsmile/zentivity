//
//  NewEventViewController.swift
//  zentivity
//
//  Created by Andrew Wen on 3/14/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class NewEventViewController: UITableViewController {
    var dateFormatter = NSDateFormatter()
    var isEditingStartDate = false
    var isEditingEndDate = false
    
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
        
        startTimePickerCell.clipsToBounds = true
        endTimePickerCell.clipsToBounds = true
        
        startTimePickerCell.bounds = CGRect(x: startTimePickerCell.center.x, y:
            startTimePickerCell.center.y, width: startTimePickerCell.bounds.width, height: 0)
        endTimePickerCell.bounds = CGRect(x: endTimePickerCell.center.x, y: endTimePickerCell.center.y, width: endTimePickerCell.bounds.width, height: 0)
        
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        var cell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
//        
//        if cell.tag == 4 {
//            return isEditingStartDate == true ? 162 : 0
//        } else if cell.tag == 6 {
//            return isEditingEndDate == true ? 162 : 0
//        } else {
//            return 44
//        }
//    }

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
        view.endEditing(true)
    }
    
    @IBAction func endDateCellTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
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
        event.descript = descriptionField.text
        event.admin = PFUser.currentUser()
        event.startTime = startTimePicker.date
        event.endTime = endTimePicker.date
        
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
