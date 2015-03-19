//
//  MenuViewController.swift
//  zentivity
//
//  Created by Eric Huang on 3/16/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var mainView: UIView!
    var mainViewLeftPos: CGFloat!
    var mainViewRightPos: CGFloat!
    var mainViewCurrentPos: CGFloat!
    var mainViewXTranslation: CGFloat!
    var eventsVC: EventsViewController!
    var menuVC: UserProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainViewLeftPos = view.center.x
        mainViewRightPos = view.center.x + view.bounds.width - 60.0;
        
        menuVC = storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as UserProfileViewController
        eventsVC = storyboard?.instantiateViewControllerWithIdentifier("EventsViewController") as EventsViewController
        
        initMenuView()
        initMainView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMenuView() {
//        var menuNVC = UINavigationController(rootViewController: menuVC)
//        menuNVC.navigationBar.topItem?.title = "Menu"
//        menuNVC.edgesForExtendedLayout = UIRectEdge.None
        self.addChildViewController(menuVC)
        menuVC.view.frame = menuView.bounds
        self.menuView.addSubview(menuVC.view)
        menuVC.didMoveToParentViewController(self)
    }
    
    func initMainView() {
        mainView.layer.shadowColor = UIColor.blackColor().CGColor
        mainView.layer.shadowOffset = CGSizeMake(-0.5, 0.5)
        mainView.layer.shadowOpacity = 0.7
        mainView.layer.shadowRadius = 0.5
        
        var hamburgerImage = UIImage(named: "menu_icon")
        var menuButton = UIBarButtonItem(image: hamburgerImage, landscapeImagePhone: hamburgerImage, style: UIBarButtonItemStyle.Plain, target: self, action: "toggleMenu")
        eventsVC.navigationItem.leftBarButtonItem = menuButton
        
//        var mainNVC = UINavigationController(rootViewController: eventsVC)
//        mainNVC.navigationBar.topItem?.title = "Events"
//        mainNVC.edgesForExtendedLayout = UIRectEdge.None
        
        let mainVC = eventsVC
        self.addChildViewController(mainVC)
        self.mainView.addSubview(mainVC.view)
        mainVC.view.frame = mainView.bounds
        mainVC.didMoveToParentViewController(self)
    }
    
    @IBAction func onMainViewPan(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            mainViewCurrentPos = mainView.center.x
        } else if sender.state == .Changed {
            var translation = sender.translationInView(view)
            var x = mainViewCurrentPos + translation.x

            if x < mainViewLeftPos {
                x = mainViewLeftPos
            } else if x > mainViewRightPos {
                x = mainViewRightPos
            }

            mainView.center.x = x
        } else if sender.state == .Ended {

        var velocity = sender.velocityInView(view)
            velocity.x < 0 ? hideMenu() : showMenu()
        }
    }
    
    func hideMenu() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mainView.center.x = self.mainViewLeftPos
        })
    }
    
    func showMenu() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mainView.center.x = self.mainViewRightPos
        })
    }
    
    func toggleMenu() {
        mainView.center.x > view.bounds.width / 2 ? hideMenu() : showMenu()
    }
}
