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
    var viewSize: CGSize = CGSize(width: 320, height: 568)
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
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView : UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        var multiplier: CGFloat = self.isScrollingLeft ? 1.0 : -1.0
        toView.frame = CGRect(x: multiplier * toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        
        multiplier = self.isScrollingLeft ? -1.0 : 1.0
        let fromViewNewFrame = CGRect(x: multiplier * fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            toView.frame = CGRect(x: 0, y: 0, width: self.viewSize.width, height: self.viewSize.height)
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
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}
