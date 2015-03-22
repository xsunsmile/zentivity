//
//  FilterViewController.swift
//  zentivity
//
//  Created by Eric Huang on 3/17/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController, UITextFieldDelegate, UISearchBarDelegate {
    
//    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var distanceSlider: UISlider!
    var isPickingDate: Bool = false { didSet { handleDatePicker() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryField.delegate = self
        
        datePicker.addTarget(self, action: "datePickerValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.frame.size.width = view.frame.width - 60
        tableView.frame.origin.x = 60
        tableView.frame.origin.y = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true) //.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func onSearch(sender: AnyObject) {
        println("Searching for category: \(categoryField.text)")
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func handleDatePicker() {
        if isPickingDate {
            datePicker.hidden = false
            dateLabel.hidden = true
            tableView.reloadData()
        } else {
            datePicker.hidden = true
           dateLabel.hidden = false
            tableView.reloadData()
        }
    }
    
    func datePickerValueChanged() {
        isPickingDate = false
        var date = datePicker.date
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        dateLabel.textColor = UIColor.blackColor()
        dateLabel.text = formatter.stringFromDate(date)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return isPickingDate ? 152 : 44
        } else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            isPickingDate = true
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        distanceLabel.text = "\(Int(sender.value)) Miles"
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isPickingDate = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
