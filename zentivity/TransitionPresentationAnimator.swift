//
//  TransitionPresentationAnimator.swift
//  zentivity
//
//  Created by Hao Sun on 3/23/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class TransitionPresentationAnimator: NSObject,
                                      UIViewControllerAnimatedTransitioning
{
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.9
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        let animationDuration = self.transitionDuration(transitionContext)

        let startRect = CGRectMake(0,
            CGRectGetHeight(containerView.frame),
            CGRectGetWidth(containerView.bounds),
            CGRectGetHeight(containerView.bounds))
        
        let transformedPoint = CGPointApplyAffineTransform(startRect.origin, toViewController.view.transform)
        toViewController.view.frame = CGRectMake(transformedPoint.x, transformedPoint.y, startRect.size.width, startRect.size.height)
        containerView.addSubview(toViewController.view)
        
        UIView.animateWithDuration(animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
            fromViewController.view.transform = CGAffineTransformMakeScale(0.9, 0.9)
            
            toViewController.view.frame = CGRectMake(0,0,
                CGRectGetWidth(toViewController.view.frame),
                CGRectGetHeight(toViewController.view.frame))
        }) { (completed) -> Void in
            fromViewController.view.transform = CGAffineTransformIdentity
            transitionContext.completeTransition(completed)
        }
    }
}
