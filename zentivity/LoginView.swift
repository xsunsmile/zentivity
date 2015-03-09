//
//  LoginView.swift
//  zentivity
//
//  Created by Hao Sun on 3/7/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class LoginView: UIView {

    @IBOutlet weak var loginIconImageView: UIImageView!
    @IBOutlet weak var loginTypeLabel: UILabel!
    @IBOutlet weak var loginButtonView: UIView!
    
    var loginBannerView: UIView!
    var buttonBackgroundColor: UIColor? {
        didSet {
            loginButtonView.backgroundColor = buttonBackgroundColor!
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    func initSubViews() {
        let nib = UINib(nibName: "LoginView", bundle: nil)
        let objects = nib.instantiateWithOwner(self, options: nil)
        loginBannerView = objects[0] as UIView
        
        if GoogleClient.sharedInstance.alreadyLogin() {
            loginTypeLabel.text = "Logout from Google"
        }
        loginBannerView.frame = bounds
        
        loginButtonView.layer.masksToBounds = true
        loginButtonView.layer.cornerRadius = 0.5
        
        addSubview(loginBannerView)
    }
    
    
    @IBAction func loginTapped(sender: UITapGestureRecognizer) {
        println("google auth button is tapped")
        
        if GoogleClient.sharedInstance.alreadyLogin() {
            GoogleClient.sharedInstance.logoutWithCompletion({ (completed) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    println("User did logout")
                    self.loginTypeLabel.text = "Signin from Google"
                })
            })
        } else {
            GoogleClient.sharedInstance.loginWithCompletion({ (completed) -> Void in
                if completed {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        println("User did login")
                        self.loginTypeLabel.text = "Logout from Google"
                    })
                }
            })
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
