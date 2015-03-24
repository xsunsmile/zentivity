//
//  TransitionDelegate.swift
//  zentivity
//
//  Created by Hao Sun on 3/23/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class TransitionDelegate: NSObject,
                          UIViewControllerTransitioningDelegate
{
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = TransitionPresentationAnimator()
        return presentationAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissalAnimator = TransitionDismissalAnimator()
        return dismissalAnimator
    }
}
