//
//  TransitionDismissalAnimator.swift
//  zentivity
//
//  Created by Hao Sun on 3/23/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class TransitionDismissalAnimator: NSObject,
                                   UIViewControllerAnimatedTransitioning,
                                   UIViewControllerInteractiveTransitioning
{
    weak var modalView: UIViewController?
    var interactive = false
    var panLocationStart = CGFloat(0)
    var transitionContext: UIViewControllerContextTransitioning!
    var tempTransform: CATransform3D!
    var fromViewController: UIViewController!
    var toViewController: UIViewController!
    var containerView: UIView!
    var animationRatio = CGFloat(0)
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if (interactive) {
            return
        }
        
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
    
    func onModalPan(pan: UIPanGestureRecognizer) {
        var velocity = pan.velocityInView(modalView!.view)
        var location = pan.locationInView(modalView!.view)
        
        if abs(velocity.x) < abs(velocity.y) {
            if !interactive && velocity.y < 0 {
                return
            }
            println("handle swipe down")
            if pan.state == .Began {
                interactive = true
                panLocationStart = location.y
                modalView?.dismissViewControllerAnimated(true, completion: nil)
                animationRatio = CGFloat(0)
            } else if pan.state == .Changed {
                location = pan.locationInView(containerView)
                animationRatio = (location.y - self.panLocationStart) / (CGRectGetHeight(modalView!.view.bounds)/2)
                updateInteractiveTransition(animationRatio)
            } else if pan.state == .Ended {
                if animationRatio > 0.2 {
                    finishInteractiveTransition()
                } else {
                    cancelInteractiveTransition()
                }
                animationRatio = CGFloat(0)
                interactive = false
            }
        } else {
            println("ignore velocity \(velocity)")
            return
        }
    }
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        println("startInteractiveTransition")
        
        self.transitionContext = transitionContext
        fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        containerView = transitionContext.containerView()
        
        self.tempTransform = toViewController.view.layer.transform
        
        toViewController.view.alpha = 0.1
        containerView.bringSubviewToFront(fromViewController.view)
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        if transitionContext == nil {
            println("transition Context missing, return from update percentage")
            return
        } else {
            println("transition percentage: \(percentComplete)")
        }
        
        var percent = percentComplete
        if percentComplete < 0 {
            percent = 0
        }
        
        if percentComplete > 1 {
            percent = 1
        }
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
        var transform = CATransform3DMakeScale(
            1 + (((1 / 0.9) - 1) * percent),
            1 + (((1 / 0.9) - 1) * percent), 1)
        toViewController.view.layer.transform = CATransform3DConcat(self.tempTransform, transform)
    
        toViewController.view.alpha = 0.1 + (1 - 0.1) * percent
    
        var updateRect = CGRectMake(0,
            (CGRectGetHeight(fromViewController.view.bounds) * percent),
            CGRectGetWidth(fromViewController.view.frame),
            CGRectGetHeight(fromViewController.view.frame))
    
        if (isnan(updateRect.origin.x) || isinf(updateRect.origin.x)) {
            updateRect.origin.x = 0;
        }
        if (isnan(updateRect.origin.y) || isinf(updateRect.origin.y)) {
            updateRect.origin.y = 0;
        }
    
        var transformedPoint = CGPointApplyAffineTransform(updateRect.origin, fromViewController.view.transform);
        updateRect = CGRectMake(transformedPoint.x, transformedPoint.y, updateRect.size.width, updateRect.size.height);
    
        fromViewController.view.frame = updateRect
    }
    
    func finishInteractiveTransition() {
        if transitionContext == nil {
            println("transition Context missing, return from finishe transition")
            return
        } else {
            println("finish transition")
        }
        
        let animationDuration = self.transitionDuration(transitionContext)
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var endRect = CGRectMake(0,
            CGRectGetHeight(fromViewController.view.bounds),
            CGRectGetWidth(fromViewController.view.frame),
            CGRectGetHeight(fromViewController.view.frame))
        
        var transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
        endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);
    
        UIView.animateWithDuration(animationDuration, delay:0, usingSpringWithDamping:0.8, initialSpringVelocity:0.1, options:.CurveEaseOut, animations: { () -> Void in
            let scaleBack = CGFloat(1)
            toViewController.view.transform = CGAffineTransformIdentity
            toViewController.view.alpha = 1.0
            fromViewController.view.frame = endRect
        }) { (completed) -> Void in
            self.transitionContext.completeTransition(completed)
        }
    }
    
    func cancelInteractiveTransition() {
        if transitionContext == nil {
            println("transition Context missing, return from cancel transition")
            return
        } else {
            println("cancel transition")
        }
        
        let animationDuration = self.transitionDuration(transitionContext)
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var endRect = CGRectMake(0,
            CGRectGetHeight(fromViewController.view.bounds),
            CGRectGetWidth(fromViewController.view.frame),
            CGRectGetHeight(fromViewController.view.frame))
        
        var transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
        endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);
        
        UIView.animateWithDuration(0.4, delay:0, usingSpringWithDamping:0.8, initialSpringVelocity:0.1, options:.CurveEaseOut, animations: { () -> Void in
                toViewController.view.layer.transform = self.tempTransform;
                toViewController.view.alpha = 0.1
                fromViewController.view.frame = CGRectMake(0,0,
                    CGRectGetWidth(fromViewController.view.frame),
                    CGRectGetHeight(fromViewController.view.frame))
            }) { (completed) -> Void in
                self.transitionContext.completeTransition(false)
        }
    }
}
