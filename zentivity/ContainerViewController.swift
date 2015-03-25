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
    var menuVC: UserProfileViewController! // UserProfileViewController!
    var currentViewControllerName: NSString!
    var menuButton: UIButton!
    var menuIsOpen = false
    var mainNVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hamburgerImage = UIImage(named: "menu_slim")
        let frame = CGRectMake(-10, 0, 18, 18)
        menuButton = UIButton(frame: frame)
        menuButton.setBackgroundImage(hamburgerImage, forState: .Normal)
        menuButton.addTarget(self, action: "toggleMenu", forControlEvents: .TouchDown)
        
        mainViewLeftPos = view.center.x + view.bounds.width - 60.0
        mainViewRightPos = view.center.x
        
        menuVC = storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as UserProfileViewController
        menuVC.delegate = self
        
        mainView.layer.shadowColor = UIColor.blackColor().CGColor
        mainView.layer.shadowOffset = CGSizeMake(-0.5, 0.5)
        mainView.layer.shadowOpacity = 0.7
        mainView.layer.shadowRadius = 0.5
        
        initMenuView()
        initListNewEventsView()
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return false
//    }
//    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }
    
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
        switchMainViewTo("EventsViewController", hasNav: true)
    }
    
    func switchMainViewTo(controllerName: NSString, hasNav: Bool) {
        removeCurrentViewController()
        let nav = UINavigationController()
        
        mainNVC = storyboard?.instantiateViewControllerWithIdentifier(controllerName) as? UIViewController
        println("add burger menu icon")
        mainNVC!.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        if hasNav {
            nav.hidesBarsOnSwipe = true
            nav.navigationBar.translucent = true
            nav.navigationBar.tintColor = UIColor(rgba: "#4fadd9")
//            nav.navigationBar.barStyle = UIBarStyle.Default
//            nav.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            //setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:UIBarMetricsDefault];
            nav.pushViewController(mainNVC!, animated: false)
            mainNVC = nav
        }
        
        self.addChildViewController(mainNVC!)
        self.mainView.addSubview(mainNVC!.view)
        mainNVC!.view.frame = mainView.bounds
        mainNVC!.didMoveToParentViewController(self)
        
        currentViewControllerName = controllerName
    }
    
    func removeCurrentViewController() {
        if currentViewControllerName != nil {
            var vc = mainNVC!
            if let nvc = mainNVC!.navigationController {
                vc = nvc
            }
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
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
        menuIsOpen = false
        UIView.animateWithDuration(0.4, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.mainView.center.x = self.mainViewRightPos
            }) { (success) -> Void in
        }
    }
    
    func showMenu() {
        menuIsOpen = true
        UIView.animateWithDuration(0.4, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.mainView.center.x = self.mainViewLeftPos
        }) { (success) -> Void in
        }
    }
    
    func toggleMenu() {
        mainView.center.x > view.bounds.width / 2 ? hideMenu() : showMenu()
    }
    
    func closeMenuAndDo(action: NSString) {
        hideMenu()
        switch(action) {
        case "listNewEvents":
            if currentViewControllerName != "EventsViewController" {
                switchMainViewTo("EventsViewController", hasNav: true)
            }
            break
        case "addEvent":
            if currentViewControllerName != "NewEventViewController" {
                switchMainViewTo("NewEventViewController", hasNav: true)
            }
            break
        case "logOut":
            if currentViewControllerName != "AppViewController" {
                switchMainViewTo("AppViewController", hasNav: false)
                if let loginVC = mainNVC as? AppViewController {
                    println("assign delegate for loginVC")
                    loginVC.delegate = self
                }
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
