//
//  FilterViewController.swift
//  zentivity
//
//  Created by Eric Huang on 3/17/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var distanceSlider: UISlider!
    var isPickingDate: Bool = false { didSet { handleDatePicker() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        categoryField.delegate = self
        
        datePicker.addTarget(self, action: "datePickerValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(sender: AnyObject) {
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func onSearch(sender: AnyObject) {
        println("Searching for title: \(titleField.text)")
        println("Searching for category: \(categoryField.text)")
        
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleDatePicker() {
        if isPickingDate {
            datePicker.hidden = false
            dateField.hidden = true
            tableView.reloadData()
        } else {
            datePicker.hidden = true
           dateField.hidden = false
            tableView.reloadData()
        }
    }
    
    func datePickerValueChanged() {
        isPickingDate = false
        var date = datePicker.date
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        dateField.textColor = UIColor.blackColor()
        dateField.text = formatter.stringFromDate(date)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == titleField {
            categoryField.becomeFirstResponder()
        } else {
            isPickingDate = true
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 3 && indexPath.row == 0 {
            return isPickingDate ? 152 : 44
        } else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            isPickingDate = true
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        distanceLabel.text = "\(Int(sender.value)) Miles"
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isPickingDate = false
    }
    
// MARK: - Table view data source
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
//        return 0
//    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
//        return 0
//    }

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
