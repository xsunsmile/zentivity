//
//  AddEventViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationFrield: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    private var datePicker = UIDatePicker()
    private var editingTarget: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
        setup()
    }
    
    func setup() {
        createButton.layer.cornerRadius = 4
        createButton.clipsToBounds = true
        
        datePicker.frame = CGRectMake(0, view.frame.height, view.frame.width, datePicker.frame.size.height)
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.addTarget(self, action: "dateValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        datePicker.timeZone = NSTimeZone.localTimeZone()
        view.addSubview(datePicker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dateValueChanged() {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy @ hh:mm a"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        let date = dateFormatter.stringFromDate(datePicker.date)
        editingTarget?.text = "\(date)"
    }
    
    func showDatePicker(target: UILabel) {
        editingTarget = target
        
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: nil, animations: { () -> Void in

            self.datePicker.frame = CGRectMake(0, self.view.frame.height - self.datePicker.frame.height, self.view.frame.width, self.datePicker.frame.size.height)
            
        }, completion: nil)
    }
    
    func hideDatePicker() {
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            
            self.datePicker.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.datePicker.frame.size.height)
            
        }, completion: nil)
    }
    
    @IBAction func onDismiss(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func onTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
        hideDatePicker()
    }
    
    @IBAction func onStartDateTapped(sender: UITapGestureRecognizer) {
        showDatePicker(sender.view as UILabel)
    }
    
    @IBAction func onEndDateTapped(sender: UITapGestureRecognizer) {
        showDatePicker(sender.view as UILabel)
    }
    
    @IBAction func onDescriptionEditBegan(sender: AnyObject) {
        hideDatePicker()
    }
    
    @IBAction func onCreate(sender: UIButton) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "MMM d, yyyy @ hh:mm a"
        
        var event = Event()
        event.title = titleField.text
        event.descript = descriptionField.text
        event.admin = PFUser.currentUser()
        event.startTime = dateFormatter.dateFromString(startTimeLabel.text!)!
        event.endTime = dateFormatter.dateFromString(endTimeLabel.text!)!
        
        // Set invitedUsernames to set invited relationship!
        event.invitedUsernames = ["awen", "ehuang", "hsun"]
        
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
    
    func initSubviews() {
        scrollView.contentSize = CGSizeMake(view.frame.width, view.frame.height)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
