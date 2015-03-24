//
//  TransitionDismissalAnimator.swift
//  zentivity
//
//  Created by Hao Sun on 3/23/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class TransitionDismissalAnimator: NSObject,
                                   UIViewControllerAnimatedTransitioning
{
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        let animationDuration = self.transitionDuration(transitionContext)
        
        containerView.bringSubviewToFront(fromViewController.view)
        toViewController.view.alpha = 0.3
        toViewController.view.transform = CGAffineTransformMakeScale(0.9, 0.9)
        
        var endRect = CGRectMake(0,
            CGRectGetHeight(fromViewController.view.bounds),
            CGRectGetWidth(fromViewController.view.frame),
            CGRectGetHeight(fromViewController.view.frame))
        let transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform)
        endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height)
        
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .CurveEaseOut, animations: { () -> Void in
            let scaleBack = CGFloat(1)
            toViewController.view.transform = CGAffineTransformIdentity
            toViewController.view.alpha = 1.0
            fromViewController.view.frame = endRect
        }) { (completed) -> Void in
            transitionContext.completeTransition(completed)
        }
    }
}
