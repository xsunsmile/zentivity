//
//  AppDelegate.swift
//  zentivity
//
//  Created by Andrew Wen on 3/5/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Parse setup
        
        User.registerSubclass()
        Photo.registerSubclass()
        Event.registerSubclass()
        Comment.registerSubclass()
        
        Parse.setApplicationId("LEwfLcFvUwXtT8A7y2dJMlHL7FLiEybY8x5kOaZP", clientKey: "YRAwfZdssZrBJtNGqE0wIEyiAaBoARiCih5hrNau")
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleGoogleLogin:", name: "userDidLoginNotification", object: nil)
        
// Add Photo for event...
//        let eventId = "FQK1CbeMLd"
//        let imageName = "zz"
//        
//        let image = UIImage(named: imageName)
//        var query = Event.query()
//        query.getObjectInBackgroundWithId(eventId, block: { (event, error) -> Void in
//            let event = event as Event
//            event.addPhotoWithCompletion(image!, completion: { (success, error) -> Void in
//                if success == true {
//                    println("SUCCESS")
//                } else {
//                    println("FAIL")
//                }
//            })
//        })
        
        
        
        
        return true
    }
    
    func loginToParseWithUserInfo(userInfo: NSDictionary) {
        let email = userInfo["email"] as String
        let name = userInfo["name"] as String
        let image = userInfo["imageUrl"] as String
        let aboutMe = userInfo["aboutMe"] as String
        
        PFCloud.callFunctionInBackground("getUserSessionToken", withParameters: ["username" : email]) { (sessionToken, error) -> Void in
            if let sessionToken = sessionToken as? String {
                PFUser.becomeInBackground(sessionToken, block: { (user, error) -> Void in
                    if error == nil {
                        // Found user with sessionToken
                        println("Logged in user with session token")
                        User.currentUser().name = name
                        User.currentUser().imageUrl = image
                        User.currentUser().aboutMe = aboutMe
                        User.currentUser().saveInBackgroundWithBlock({ (success, error) -> Void in
                            // Nothing now
                        })
                        self.showEventsVC()
                    } else {
                        // Could not find user with sessionToken
                        // SUPER FAIL!
                        println("SUPER FAIL!")
                    }
                    
                })
            } else {
                // Could not find user email
                var user = User()
                user.username = email
                user.password = "1"
                user.name = name
                user.imageUrl = image
                user.aboutMe = aboutMe
                
                ParseClient.setUpUserWithCompletion(user, completion: { (user, error) -> () in
                    if error == nil {
                        // User signed up/logged in
                        // Set up some views..
                        self.showEventsVC()
                    } else {
                        // User failed to sign up and log in
                        println("Failed to sign up and log in user")
                        println(error)
                    }
                })
            }
        }
    }
    
    func handleGoogleLogin(notification: NSNotification) {
        loginToParseWithUserInfo(notification.userInfo!)
    }
    
    func showEventsVC() {
        let scence = "MenuViewController"
        let vc = storyboard.instantiateViewControllerWithIdentifier(scence) as UIViewController
        window?.rootViewController = vc
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        println("redirect to url: \(url)")
        return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }

}

