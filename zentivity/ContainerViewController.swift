//
//  MenuViewController.swift
//  zentivity
//
//  Created by Eric Huang on 3/16/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController,
                               UserProfileViewControllerDelegate,
                               AppViewControllerDelegate
{
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var mainView: UIView!
    var mainViewLeftPos: CGFloat!
    var mainViewRightPos: CGFloat!
    var mainViewCurrentPos: CGFloat!
    var mainViewXTranslation: CGFloat!
    var eventsVC: EventsViewController!
    var menuVC: UserProfileViewController! // UserProfileViewController!
    var currentViewController: UIViewController!
    var addEventVC: NewEventViewController!
    var loginVC: AppViewController!
    var menuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let hamburgerImage = UIImage(named: "menu_slim")
        let frame = CGRectMake(-10, 0, 18, 18)
        menuButton = UIButton(frame: frame)
        menuButton.setBackgroundImage(hamburgerImage, forState: .Normal)
        menuButton.addTarget(self, action: "toggleMenu", forControlEvents: .TouchDown)
        
        
        
        mainViewLeftPos = view.center.x + view.bounds.width - 60.0
        mainViewRightPos = view.center.x
        
        menuVC = storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as UserProfileViewController // UserProfileViewController
        menuVC.delegate = self
        
        eventsVC = storyboard?.instantiateViewControllerWithIdentifier("EventsViewController") as EventsViewController
        addEventVC = storyboard?.instantiateViewControllerWithIdentifier("NewEventViewController") as NewEventViewController
        
        addEventVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        loginVC = storyboard?.instantiateViewControllerWithIdentifier("AppViewController") as AppViewController
    
        loginVC.delegate = self
        loginVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        mainView.layer.shadowColor = UIColor.blackColor().CGColor
        mainView.layer.shadowOffset = CGSizeMake(-0.5, 0.5)
        mainView.layer.shadowOpacity = 0.7
        mainView.layer.shadowRadius = 0.5
        
        
        
        
        
        initMenuView()
        initListNewEventsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initMenuView() {
        self.addChildViewController(menuVC)
        menuVC.view.frame = menuView.bounds
        self.menuView.addSubview(menuVC.view)
        menuVC.didMoveToParentViewController(self)
    }
    
    func initListNewEventsView() {
//        let hamburgerImage = UIImage(named: "menu_slim")
//        let frame = CGRectMake(-10, 0, 18, 18)
//        let menuButton = UIButton(frame: frame)
//        menuButton.setBackgroundImage(hamburgerImage, forState: .Normal)
//        menuButton.addTarget(self, action: "toggleMenu", forControlEvents: .TouchDown)
        eventsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        switchMainViewTo(eventsVC, hasNav: true)
    }
    
    func switchMainViewTo(controller: UIViewController, hasNav: Bool) {
        removeCurrentViewController()
        
        var mainNVC = controller
        if hasNav {
            mainNVC = UINavigationController(rootViewController: controller)
        }
        
        self.addChildViewController(mainNVC)
        self.mainView.addSubview(mainNVC.view)
        mainNVC.view.frame = mainView.bounds
        mainNVC.didMoveToParentViewController(self)
        
        currentViewController = controller
    }
    
    func removeCurrentViewController() {
        if currentViewController != nil {
            currentViewController.willMoveToParentViewController(nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParentViewController()
        }
    }
    
    @IBAction func onMainViewPan(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            mainViewCurrentPos = mainView.center.x
        } else if sender.state == .Changed {
            var translation = sender.translationInView(view)
            var x = mainViewCurrentPos + translation.x

            if x > mainViewLeftPos {
                x = mainViewLeftPos
            } else if x < mainViewRightPos {
                x = mainViewRightPos
            }

            mainView.center.x = x
        } else if sender.state == .Ended {

        var velocity = sender.velocityInView(view)
            velocity.x < 0 ? hideMenu() : showMenu()
        }
    }
    
    func hideMenu() {
        UIView.animateWithDuration(0.4, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.mainView.center.x = self.mainViewRightPos
        }, completion: nil )
    }
    
    func showMenu() {
        UIView.animateWithDuration(0.4, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.mainView.center.x = self.mainViewLeftPos
        }) { (success) -> Void in
            self.menuVC.refresh()
        }
    }
    
    func toggleMenu() {
        mainView.center.x > view.bounds.width / 2 ? hideMenu() : showMenu()
    }
    
    func closeMenuAndDo(action: NSString) {
        hideMenu()
        switch(action) {
        case "listNewEvents":
            if currentViewController != eventsVC {
                switchMainViewTo(eventsVC, hasNav: true)
            }
            break
        case "addEvent":
            if currentViewController != addEventVC {
                switchMainViewTo(addEventVC, hasNav: true)
            }
            break
        case "logOut":
            if currentViewController != loginVC {
                switchMainViewTo(loginVC, hasNav: false)
            }
            break
        default:
            println("Skip perform action \(action)")
        }
    }
    
    func cancelLogin() {
        showMenu()
    }
}
