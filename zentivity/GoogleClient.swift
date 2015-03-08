//
//  GoogleClient.swift
//  zentivity
//
//  Created by Hao Sun on 3/7/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit


class GoogleClient: NSObject {
    let clientId = "502965285809-1aoq6sfjm9v9q6nvnrbbatnef1cojrv8.apps.googleusercontent.com"
    let clientSecret = "0eDWowwA0U60_skGgClQXEN5"
    let scope =  NSSet(array: ["https://www.googleapis.com/auth/plus.login"])
    let authURL = NSURL(string: "https://accounts.google.com/o/oauth2/auth")
    let tokenURL = NSURL(string: "https://www.googleapis.com/oauth2/v3/token")
    let redirectURL = NSURL(string: "urn:ietf:wg:oauth:2.0:oob")
    
    class var sharedInstance: GoogleClient {
        struct Singleton {
            static let instance = GoogleClient()
        }
        return Singleton.instance
    }
    
    func login() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "UserDidLogin:", name: NXOAuth2AccountStoreAccountsDidChangeNotification, object: NXOAuth2AccountStore.sharedStore())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "UserFailedLogin:", name: NXOAuth2AccountStoreDidFailToRequestAccessNotification, object: NXOAuth2AccountStore.sharedStore())
        
        NXOAuth2AccountStore.sharedStore().setClientID(
            clientId,
            secret: clientSecret,
            scope: scope,
            authorizationURL: authURL!,
            tokenURL: tokenURL!,
            redirectURL: redirectURL!,
            keyChainGroup: "Google",
            forAccountType: "Google"
        )
        
        NXOAuth2AccountStore.sharedStore().requestAccessToAccountWithType("Google",
            withPreparedAuthorizationURLHandler: { (url: NSURL!) -> Void in
        })
    }
    
    func userDidLogin(notification: NSNotification) {
        let userInfo = notification.userInfo as Dictionary!
        if userInfo != nil {
            //account added, we have access
            //we can now request protected data
            println("user did login: \(notification.userInfo)")
        } else {
            //account removed, we lost access
        }
    }
    
    func userFailedLogin(notification: NSNotification) {
        let userInfo = notification.userInfo as Dictionary!
        let error: AnyObject? = userInfo[NXOAuth2AccountStoreErrorKey]
        println("user failed login: \(error)")
    }
}
