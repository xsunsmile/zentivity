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
    
    var loginBannerView: UIView!
    @IBOutlet weak var authWebView: UIWebView!
    
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
        
        loginBannerView.frame = bounds
        addSubview(loginBannerView)
    }
    
    
    @IBAction func loginTapped(sender: UITapGestureRecognizer) {
        println("login is tapped")
        GoogleClient.sharedInstance.login()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
