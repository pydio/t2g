//
//  T2GNaviViewController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 13/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom UINavigationController that enables slight delay between segues (for enter/exit animation) and that adds status bar background on top of the navigation bar (settable).
*/
class T2GNaviViewController: UINavigationController {
    /// Default value is 0 - no delay.
    var segueDelay: Double = 0.0
    var statusBarBackgroundView: UIView?
    var menuDelegate: T2GNavigationBarMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    Adds status bar view behind the status bar for graphical effect.
    
    :returns: The status bar background view.
    */
    func addStatusBarBackgroundView() -> UIView {
        if let view = self.view.viewWithTag(T2GViewTags.statusBarBackgroundView) {
            return view
        } else {
            let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 20))
            view.tag = T2GViewTags.statusBarBackgroundView
            view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07)
            self.view.addSubview(view)
            return view
        }
    }
    
    /**
    Pops current view controller. In case previous view controller in the stack has isHidingEnabled flag set to true, it shows the bar so it doesn't mess up with the UI while animating the cells on the way back.
    
    :param: animated Default Cocoa API behavior - Set this value to YES to animate the transition.
    :returns: The view controller that was popped from the stack.
    */
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        var poppedViewController = super.popViewControllerAnimated(animated)
        if let visibleViewController = self.visibleViewController as? T2GViewController {
            if visibleViewController.isHidingEnabled {
                visibleViewController.showBar(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            }
            
            visibleViewController.scrollView.animateSubviewCells(isGoingOffscreen: false)
        }
        return poppedViewController
    }
    
    /**
    Pushes new view controller on the stack with delay. The delay serves to create a gap to let exit animation be more visible.
    
    :param: viewController The view controller to push onto the stack.
    :param: animated Default Cocoa API behavior - Specify YES to animate the transition or NO if you do not want the transition to be animated.
    */
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        if let viewController = self.visibleViewController as? T2GViewController {
            if viewController.isHidingEnabled {
                viewController.showBar(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            }
            
            viewController.scrollView.animateSubviewCells(isGoingOffscreen: true)
        }
        
        self.delay(self.segueDelay, closure: { () -> Void in
            self.performPush(viewController, animated: animated)
        })
    }
    
    /**
    Helper method to perform delay dispatch (unable to call the same method inside dispatch_after) of push.
    
    :param: viewController The view controller to push onto the stack.
    :param: animated Default Cocoa API behavior - Specify YES to animate the transition or NO if you do not want the transition to be animated.
    */
    func performPush(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    /**
    Helper method that dispatches method after certain time passes.
    
    :param: delay Time to wait before closure is called.
    :param: closure Closure to be performed after the delay time passes.
    */
    func delay(delay: Double, closure:() -> Void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    /**
    Proxy function of toggleBarMenu(forceClose) for UIBarButtonItem action call.
    */
    func toggleBarMenu() {
        self.toggleBarMenu(false)
    }
    
    /**
    Opens/collapses navigation bar menu which slides below from the top of the navigation bar. Works like a switch on default, but is able to accept flag forcing the menu to disappear (handy to use when VC is about to be rotated and it is not desired to have a menu opened).
    
    :param: forceClose Boolean flag indicating whether toggle should be automatic or forced close only.
    */
    func toggleBarMenu(forceClose: Bool) {
        let height: CGFloat = 64.0 * 3.0
        
        let dismissClosure = { () -> Bool in
            if let menu = self.view.viewWithTag(T2GViewTags.navigationBarMenu) {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    menu.frame = CGRectMake(0, self.navigationBar.frame.size.height - height, self.navigationBar.frame.size.width, height)
                }, completion: { (_) -> Void in
                    menu.removeFromSuperview()
                })
                return true
            } else {
                return false
            }
        }
        
        if forceClose {
            dismissClosure()
        } else {
            if !dismissClosure() {
                let menu = T2GNavigationBarMenu(frame: CGRectMake(0, self.navigationBar.frame.size.height - height, self.navigationBar.frame.size.width, height), itemCount: 3, delegate: self.menuDelegate)
                menu.tag = T2GViewTags.navigationBarMenu
                menu.backgroundColor = .whiteColor()
                menu.layer.masksToBounds = false
                menu.layer.shadowOffset = CGSizeMake(0, 6)
                menu.layer.shadowRadius = 2.0
                menu.layer.shadowOpacity = 0.45
                self.view.insertSubview(menu, belowSubview: self.navigationBar)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    menu.frame = CGRectMake(0, self.navigationBar.frame.size.height + 20.0, self.navigationBar.frame.size.width, height)
                })
            }
        }
    }
}
