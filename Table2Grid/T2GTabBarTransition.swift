//
//  TransitioningObject.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 30/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom class for transition between view controllers in T2GTabBarViewController.
*/
class T2GTabBarTransition: NSObject, UIViewControllerAnimatedTransitioning {
    /// iPhone 5 by default. Should be changed before applying the transition.
    var viewSize: CGSize = CGSizeMake(320, 568)
    var isScrollingLeft = true
    
    /**
    Convenience initializer for the transition.
    
    :param: viewSize Size of the views we are dealing with.
    :param: isScrollingLeft Boolean flag determining whether the animation should be to the left or to the right.
    */
    convenience init(viewSize: CGSize, isScrollingLeft: Bool) {
        self.init()
        
        self.viewSize = viewSize
        self.isScrollingLeft = isScrollingLeft
    }
    
    /**
    Performs the slidingh animation.
    
    :param: transitionContext Default Cocoa API - The context object containing information about the transition.
    */
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromView : UIView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView : UIView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        transitionContext.containerView().addSubview(fromView)
        transitionContext.containerView().addSubview(toView)
        
        var multiplier: CGFloat = self.isScrollingLeft ? 1.0 : -1.0
        toView.frame = CGRectMake(multiplier * toView.frame.width, 0, toView.frame.width, toView.frame.height)
        
        multiplier = self.isScrollingLeft ? -1.0 : 1.0
        let fromViewNewFrame = CGRectMake(multiplier * fromView.frame.width, 0, fromView.frame.width, fromView.frame.height)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            toView.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height)
            fromView.frame = fromViewNewFrame
        }, completion: { (_) -> Void in
            transitionContext.completeTransition(true)
        })
    }
    
    /**
    Determines the length of the transition.
    
    :param: transitionContext Default Cocoa API - The context object containing information to use during the transition.
    :returns: Default Cocoa API - The duration, in seconds, of your custom transition animation.
    */
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
}
