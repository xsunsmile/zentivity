//
//  AppViewController.swift
//  zentivity
//
//  Created by Hao Sun on 3/7/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
protocol AppViewControllerDelegate : class {
    func cancelLogin()
}

class AppViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var loginView: LoginView!
    weak var delegate: AppViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubViews()
    }
    
    func initSubViews() {
        loginView.backgroundColor = UIColor.clearColor()
        loginView.buttonBackgroundColor = UIColor(rgba: "#dd4b39")
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        backgroundImageView.setImageToBlur(backgroundImageView.image, completionBlock: { () -> Void in
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.cancelLogin()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
