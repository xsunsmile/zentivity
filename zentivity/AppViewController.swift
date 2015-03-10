//
//  AppViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/7/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {
    
    @IBOutlet weak var loginView: LoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventsList", name: userDidLoginNotification, object: nil)
        initSubViews()
    }
    
    func initSubViews() {
        view.backgroundColor = UIColor(rgba: "#78A300")
        loginView.backgroundColor = UIColor(rgba: "#78A300")
        loginView.buttonBackgroundColor = UIColor(rgba: "#dd4b39")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showEventsList() {
        performSegueWithIdentifier("eventsListSegue", sender: self)
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
