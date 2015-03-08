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
        
        initSubViews()
    }
    
    func initSubViews() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
