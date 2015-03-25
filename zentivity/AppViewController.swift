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
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
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
        
//        backgroundImageView.setImageToBlur(backgroundImageView.image, completionBlock: { () -> Void in
//        })
        
//        cancelButton.layer.borderWidth = CGFloat(2)
//        cancelButton.layer.borderColor = UIColor(rgba: "#34b5e5").CGColor
//        applyGradient()
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    func applyGradient() {
        let gradient = CAGradientLayer()
        let arrayColors = [
            UIColor.clearColor().CGColor,
            UIColor.whiteColor().CGColor
        ]
        
        gradientView.backgroundColor = UIColor.clearColor()
        gradient.frame = view.bounds
        gradient.colors = arrayColors
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
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
