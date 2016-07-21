//
//  T2GNaviViewController.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 13/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Extension of UINavigationController to support completion handler when popped to view controller.
*/
extension UINavigationController {
    
    /**
    Pops to given viewController in transaction and performs given closure when popping has ended.
    
    :param: vc View controller to be popped to.
    :param: handler Optional handler to be performed after popping has ended.
    */
    func popToViewControllerWithHandler(vc: UIViewController, handler: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(handler)
        self.popToViewController(vc, animated: true)
        CATransaction.commit()
    }
}

/**
Extension of UIViewController to obtain completion handler when popped to the view controller.
*/
extension UIViewController {
    
    /**
    Returns completion closure to be performed.
    
    :returns: Optional closure.
    */
    func completionHandlerWhenAppeared() -> (() -> Void)? {
        return nil
    }
}

/**
Protocol for path view controller setup - prependable content and icons for view controllers. Does not need to be implemented to fully function. Serves for esthetical reasons.
*/
protocol T2GNaviPathDelegate {
    
    /**
    Gets called when path is being built to know how many items should be prepended.
    
    :returns: Number of items to be prepended.
    */
    func pathPrependableItemCount() -> Int
    
    /**
    Gets called after the pathPrependableItemCount method in a for cycle from 0 to n to obtain attributes for all prependable items.
    
    - DISCUSSION: Could be made as returning optional, since Swift doesn't provide optional protocol methods. But then again, this method doesn't get called if the count is 0, so it can be implemented with a one-liner `{ return ("", "") }`
    
    :param: index Index of the prependable item.
    :returns: Tuple with the name and the image name to use.
    */
    func pathPrependableItemAttributes(index: Int) -> (name: String, image: String)
    
    /**
    Gets called when prepended item is selected. In some cases it could be desirable to pop all the way to the root and sometimes not - that's when this method comes in. Is called every time any prependable index is selected.
    
    :param: index Index of the prependable item.
    :returns: Boolean flag stating whether or not should the view hierarchy should be popped to its root.
    */
    func shouldPopToRootWhenPrependedIndexIsSelected(index: Int) -> Bool
    
    /**
    Gets called when path is being built to know what icon to use for the given view controller.
    
    :param: viewController UIViewController on the stack of viewControllers in UINavigationController.
    :returns: Image asset name.
    */
    func pathImageForViewController(viewController: UIViewController) -> String
    
    /**
    Gets called when prependable item on given index got selected.
    
    :param: index Index of the prepended item.
    */
    func didSelectPrependableIndex(index: Int)
}

/**
Custom UINavigationController that enables slight delay between segues (for enter/exit animation) and that adds status bar background on top of the navigation bar (settable).
*/
class T2GNaviViewController: UINavigationController, UIPopoverPresentationControllerDelegate, T2GPathViewControllerDelegate {
    /// Default value is 0 - no delay.
    var segueDelay: Double = 0.0
    var statusBarBackgroundView: UIView?
    var pathDelegate: T2GNaviPathDelegate?

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
        
        let poppedViewController = super.popViewControllerAnimated(animated)
        if let visibleViewController = self.visibleViewController as? T2GViewController {
            if visibleViewController.isHidingEnabled {
                visibleViewController.showBar(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
            }
            
            visibleViewController.scrollView.animateSubviewCells(false)
        }
        return poppedViewController
    }
    
    /**
    Pushes new view controller on the stack with delay. The delay serves to create a gap to let exit animation be more visible.
    
    :param: viewController The view controller to push onto the stack.
    :param: animated Default Cocoa API behavior - Specify YES to animate the transition or NO if you do not want the transition to be animated.
    */
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        
        if let vc = self.visibleViewController as? T2GViewController {
            if vc.isHidingEnabled {
                vc.showBar(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
            }
            
            vc.scrollView.animateSubviewCells(true)
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
    
    //MARK: - UIPopover controller methods
    
    /**
    Instantiates and shows PathView controller as UIPopover.
    
    :param: sender UIButton from which the PathView controller will be shown.
    */
    func showPathPopover(sender: UIButton) {
        let pathViewController = T2GPathViewController()
        pathViewController.modalPresentationStyle = .Popover
        pathViewController.preferredContentSize = CGSizeMake(self.view.frame.width * 0.8, 256)
        pathViewController.path = self.buildPath()
        pathViewController.prependedItemCount = self.pathDelegate?.pathPrependableItemCount() ?? 0
        pathViewController.pathDelegate = self
        
        let popoverMenuViewController = pathViewController.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .Any
        popoverMenuViewController?.delegate = self
        popoverMenuViewController?.sourceView = sender
        
        popoverMenuViewController?.sourceRect = CGRect(x: sender.frame.size.width / 2, y: sender.frame.size.height - 5, width: 1, height: 1)
        self.presentViewController(pathViewController, animated: true, completion: nil)
    }
    
    /**
    Helper method for when PathView controller gets presented as UIPopover.
    
    :param: controller Default Cocoa API - The presentation controller that is managing the size change.
    :returns: Default Cocoa API - The new presentation style, which must be either UIModalPresentationFullScreen or UIModalPresentationOverFullScreen.
    */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    /**
    Builds path comprising of all ViewControllers on the stack.
    
    :returns: Array of Dictionary objects containing name and image to be displayed.
    */
    func buildPath() -> [[String : String]] {
        var path = [[String : String]]()
        
        if let prependableCount = self.pathDelegate?.pathPrependableItemCount() {
            for index in 0..<prependableCount {
                let attributes = self.pathDelegate!.pathPrependableItemAttributes(index)
                path.append(["name" : attributes.name, "image" : attributes.image])
            }
        }
        
        for vc in (self.viewControllers) {
            let image = self.pathDelegate?.pathImageForViewController(vc) ?? ""
            let title = vc.title ?? "/"
            path.append(["name" : title, "image" : image])
        }
        
        return path
    }
    
    //MARK: T2GPathViewController delegate methods
    
    /**
    Redirects to pathDelegate.
    
    :returns: Boolean flag indicating whether to pop or not - if pathDelegate is nil, returns false.
    */
    func shouldPopToRootWhenPrependedIndexIsSelected(index: Int) -> Bool {
        return self.pathDelegate?.shouldPopToRootWhenPrependedIndexIsSelected(index) ?? false
    }
    
    /**
    Redirects to pathDelegate.
    
    :param: index Index of the prepended item.
    */
    func didSelectPrependedIndex(index: Int) {
        self.pathDelegate?.didSelectPrependableIndex(index)
    }
    
    /**
    Pops to selected ViewController on the stack.
    
    :param: index Index of the selected ViewController.
    */
    func didSelectViewController(index: Int, completion: (() -> Void)?) {
        let vc = self.viewControllers[index]
        
        if let t2gVC = vc as? T2GViewController {
            if t2gVC.isHidingEnabled {
                t2gVC.showBar(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
            }
            
            t2gVC.scrollView.animateSubviewCells(false)
        }
        
        self.popToViewControllerWithHandler(vc, handler: completion)
    }
    
    /**
    Returns closure to be performed when root view controller appears.
    
    :returns: Optional closure.
    */
    func completionHandlerAfterRootViewControllerAppears() -> (() -> Void)? {
        let uivc: UIViewController? = self.viewControllers[0]
        
        if let vc = uivc {
            return vc.completionHandlerWhenAppeared()
        }
        
        return nil
    }
}
