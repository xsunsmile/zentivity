//
//  GoogleClient.swift
//  zentivity
//
//  Created by Hao Sun on 3/7/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class GoogleClient: NSObject,
                    GPPSignInDelegate
{
    let clientId = "502965285809-1aoq6sfjm9v9q6nvnrbbatnef1cojrv8.apps.googleusercontent.com"
    let scopes =  ["https://www.googleapis.com/auth/plus.login"]
    let signIn = GPPSignIn.sharedInstance()
    let plusService = GTLServicePlus()
    
    class var sharedInstance: GoogleClient {
        struct Singleton {
            static let instance = GoogleClient()
        }
        return Singleton.instance
    }
    
    override init() {
        signIn.shouldFetchGooglePlusUser = true
        signIn.shouldFetchGoogleUserEmail = true
        signIn.clientID = clientId
        signIn.scopes = scopes
        
        plusService.retryEnabled = true
    }
    
    func login() {
        signIn.delegate = self
        if !signIn.trySilentAuthentication() {
            signIn.authenticate()
        }
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if auth != nil {
            plusService.authorizer = auth
            getUserProfile()
        } else {
            
        }
    }
    
    func getUserProfile() {
        let query = GTLQueryPlus.queryForPeopleGetWithUserId("me") as GTLQueryPlus
        plusService.executeQuery(query, completionHandler: { (ticket, person, error) -> Void in
            if error != nil {
                NSLog("%@", error)
            } else {
                let user = person as GTLPlusPerson
                NSLog("user %@", user)
                NSLog("user name: %@, about: %@", user.displayName, user.name)
            }
        })
    }
}
