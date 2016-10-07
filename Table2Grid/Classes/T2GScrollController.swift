//
//  T2GScrollController.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 23/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Enum for defining the state in which the scrollView is when UIRefreshControl has been pulled down and will "snap" back in the near future.
*/
public enum T2GAutomaticScrollViewSnapStatus {
    case none
    case willSnap
    case didSnap
    
    init(){
        self = .none
    }
}

/**
Enum defining scrolling direction. Used for recognizing whether the bar should be hidden or revealed.
*/
enum T2GScrollDirection {
    case up
    case down
    
    init(){
        self = .up
    }
}

/**
Custom UIViewController that implements hiding feature of UINavigationBar when both scrollView and navigationBar are present. Thanks to neat Swift optionals it will not crash when neither is present.
*/
open class T2GScrollController: UIViewController {
    /// functionality is enabled by default
    open var isHidingEnabled = true
    var statusBarBackgroundView: UIView?
    
    var lastScrollViewContentOffset: CGFloat = 0
    var scrollDirection: T2GScrollDirection = T2GScrollDirection()
    open var automaticSnapStatus: T2GAutomaticScrollViewSnapStatus = T2GAutomaticScrollViewSnapStatus()

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    Shows bar while rotating to landscape mode - since iOS 8 introduced the smaller version of the bar, it would totally mess up the whole layout.
    
    :param: toInterfaceOrientation Default Cocoa API - The new orientation for the user interface.
    :param: duration Default Cocoa API - The duration of the pending rotation, measured in seconds.
    */
    override open func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if isHidingEnabled {
            showBar(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        }
    }

    
    

    
    /**
    Helper method for subclasses to override if there is some extra work to be done after the view has snapped back.
    */
    func handleSnapBack() {
        // meant to be overridden
    }
    
    /**
    Creates new dummy stripe bar (if it does not already exist - otherwise it just returns what's already there) that overlays the UINavigationBar that is partially hidden. It is here, because in case buttons are present in the navigation bar then they "sort of" overlap into the whole view and it looks rather uninviting. That's where this overlay comes in to make it visually more appealing.
    
    :param: navigationCtr The UINavigationController in which the minified stripe view should be initialized.
    :returns: The UIView that has been added to the UINavigationController passed in the parameters.
    */
    func createMinifiedStripeBar(_ navigationCtr: UINavigationController) -> UIView {
        if let blackstripe = navigationCtr.view.viewWithTag(5555) {
            return blackstripe
        } else {
            let blackstripe2 = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
            blackstripe2.tag = 5555
            blackstripe2.backgroundColor = UIColor(named: .pydOrange)
            blackstripe2.isHidden = true
            navigationCtr.view.addSubview(blackstripe2)
            return blackstripe2
        }
    }
    
    /**
    Helper method to show the bar whatever is going on. Comes in handy when the device is about to be rotated or new view controller is about to be pushed on the stack.
    
    :param: isLandscape Flag determining which kind of navigation bar we'll be dealing with (minified version since iOS 8).
    */
    func showBar(_ isLandscape: Bool) {
        if let navigationCtr = self.navigationController {
            if let blackstripe = navigationCtr.view.viewWithTag(5555) {
                blackstripe.removeFromSuperview()
            }
            
            var statusBarBackgroundViewFrame = self.statusBarBackgroundView?.frame
            var barFrame = navigationCtr.navigationBar.frame
            statusBarBackgroundViewFrame?.origin.y = isLandscape ? -20 : 0
            self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
            
            barFrame.origin.y = isLandscape ? 0 : 20
            navigationCtr.navigationBar.frame = barFrame
        }
    }
}

// MARK: - UIScrollViewDelegate
extension T2GScrollController: UIScrollViewDelegate {
    /**
     Handles the end of scrolling event, to make sure the navigation bar doesn't end up in inconsistent state (hides/shows).
     
     :param: scrollView Default Cocoa API - The scroll-view object that finished scrolling the content view.
     :param: willDecelerate Default Cocoa API - true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
     */
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isHidingEnabled {
            if let navigationCtr = self.navigationController {
                if ((navigationCtr.navigationBar.frame.origin.y != 20 || navigationCtr.navigationBar.frame.origin.y != -24) && UIDeviceOrientationIsPortrait(UIDevice.current.orientation)) {
                    
                    if (self.scrollDirection == .down) {
                        // hide
                        
                        var statusBarBackgroundViewFrame = self.statusBarBackgroundView?.frame
                        var barFrame = navigationCtr.navigationBar.frame;
                        let blackstripe = self.createMinifiedStripeBar(navigationCtr)
                        
                        statusBarBackgroundViewFrame?.origin.y = -44
                        barFrame.origin.y = -24
                        
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            blackstripe.isHidden = false
                            self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                            navigationCtr.navigationBar.frame = barFrame
                        })
                        
                    } else {
                        // show
                        
                        var statusBarBackgroundViewFrame = self.statusBarBackgroundView?.frame
                        var barFrame = navigationCtr.navigationBar.frame
                        
                        if let blackstripe = navigationCtr.view.viewWithTag(5555) {
                            blackstripe.removeFromSuperview()
                        }
                        
                        statusBarBackgroundViewFrame?.origin.y = 0
                        barFrame.origin.y = 20
                        
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                            navigationCtr.navigationBar.frame = barFrame
                        })
                    }
                }
            }
        }
    }
    
    /**
     Gets called every time the scrollView moves - even when UIRefreshControl is the one making the movement. This method handles all those events and acts accordingly - moves the navigation bar up/down and in case of snapping back it calls handleSnapBack method.
     
     :param: scrollView Default Cocoa API - The scroll-view object in which the scrolling occurred.
     */
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isHidingEnabled {
            if let navigationCtr = navigationController {
                if (isViewLoaded && view.window != nil && UIDeviceOrientationIsPortrait(UIDevice.current.orientation)) {
                    // check when refresher is refreshing
                    if (automaticSnapStatus == .none) {
                        if (lastScrollViewContentOffset > scrollView.contentOffset.y) {
                            scrollDirection = .up
                            
                            if scrollView.contentSize.height - 1 < scrollView.contentOffset.y + scrollView.frame.size.height {
                                automaticSnapStatus == .willSnap
                            } else {
                                // show
                                // legacy code : && !(568 >= scrollView.contentSize.height - scrollView.contentOffset.y)
                                
                                if (!(scrollView.contentOffset.y < -64.0)) {
                                    var statusBarBackgroundViewFrame = statusBarBackgroundView?.frame
                                    var barFrame = navigationCtr.navigationBar.frame
                                    
                                    if (barFrame.origin.y <= 19) {
                                        if let blackstripe = navigationCtr.view.viewWithTag(5555) {
                                            blackstripe.removeFromSuperview()
                                        }
                                        
                                        let toMove = lastScrollViewContentOffset - scrollView.contentOffset.y
                                        if (barFrame.origin.y + toMove < 20) {
                                            statusBarBackgroundViewFrame?.origin.y += toMove
                                            barFrame.origin.y += toMove
                                        } else {
                                            statusBarBackgroundViewFrame?.origin.y = 0;
                                            barFrame.origin.y = 20;
                                        }
                                        
                                        statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                                        navigationCtr.navigationBar.frame = barFrame
                                    } else {
                                        statusBarBackgroundViewFrame?.origin.y = 0;
                                        statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                                        
                                        barFrame.origin.y = 20;
                                        navigationCtr.navigationBar.frame = barFrame
                                    }
                                }
                            }
                        } else if (lastScrollViewContentOffset < scrollView.contentOffset.y) {
                            scrollDirection = .down
                            // hide
                            // legacy code: && !(568 >= scrollView.contentSize.height - scrollView.contentOffset.y)
                            
                            let scrollHandler = { () -> Void in
                                if (!(scrollView.contentOffset.y < -64.0)) {
                                    var statusBarBackgroundViewFrame = self.statusBarBackgroundView?.frame
                                    
                                    var barFrame = navigationCtr.navigationBar.frame
                                    if (barFrame.origin.y > -23) {
                                        let toMove = self.lastScrollViewContentOffset - scrollView.contentOffset.y
                                        statusBarBackgroundViewFrame?.origin.y += toMove
                                        barFrame.origin.y += toMove
                                    } else {
                                        //                                        var blackstripe = self.createMinifiedStripeBar(navigationCtr)
                                        statusBarBackgroundViewFrame?.origin.y = -44;
                                        barFrame.origin.y = -24;
                                    }
                                    self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                                    navigationCtr.navigationBar.frame = barFrame
                                }
                            }
                            
                            if let ref = scrollView.viewWithTag(T2GViewTags.refreshControl) {
                                if !scrollView.bounds.contains(ref.bounds) {
                                    scrollHandler()
                                }
                            } else {
                                scrollHandler()
                            }
                        }
                        self.lastScrollViewContentOffset = scrollView.contentOffset.y
                    } else {
                        if(scrollView.contentOffset.y == -64) {
                            if (automaticSnapStatus == .willSnap) {
                                automaticSnapStatus = .didSnap
                            } else {
                                automaticSnapStatus = .none
                                handleSnapBack()
                            }
                        }
                    }
                } else {
                    scrollDirection = lastScrollViewContentOffset > scrollView.contentOffset.y ? .up : .down
                    lastScrollViewContentOffset = scrollView.contentOffset.y
                }
            }
        } else {
            scrollDirection = lastScrollViewContentOffset > scrollView.contentOffset.y ? .up : .down
            lastScrollViewContentOffset = scrollView.contentOffset.y
        }
    }

}
