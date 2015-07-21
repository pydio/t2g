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
enum T2GAutomaticScrollViewSnapStatus {
    case None
    case WillSnap
    case DidSnap
    
    init(){
        self = .None
    }
}

/**
Enum defining scrolling direction. Used for recognizing whether the bar should be hidden or revealed.
*/
enum T2GScrollDirection {
    case Up
    case Down
    
    init(){
        self = .Up
    }
}

/**
Custom UIViewController that implements hiding feature of UINavigationBar when both scrollView and navigationBar are present. Thanks to neat Swift optionals it will not crash when neither is present.
*/
class T2GScrollController: UIViewController, UIScrollViewDelegate {
    /// functionality is enabled by default
    var isHidingEnabled = true
    var statusBarBackgroundView: UIView?
    var statusBarBackgroundViewColor = UIColor(named: .PYDOrange)
    
    var lastScrollViewContentOffset: CGFloat = 0
    var scrollDirection: T2GScrollDirection = T2GScrollDirection()
    var automaticSnapStatus: T2GAutomaticScrollViewSnapStatus = T2GAutomaticScrollViewSnapStatus()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    Shows bar while rotating to landscape mode - since iOS 8 introduced the smaller version of the bar, it would totally mess up the whole layout.
    
    :param: toInterfaceOrientation Default Cocoa API - The new orientation for the user interface.
    :param: duration Default Cocoa API - The duration of the pending rotation, measured in seconds.
    */
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if self.isHidingEnabled {
            self.showBar(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        }
    }

    //MARK: - Scroll view delegate
    
    /**
    Handles the end of scrolling event, to make sure the navigation bar doesn't end up in inconsistent state (hides/shows).
    
    :param: scrollView Default Cocoa API - The scroll-view object that finished scrolling the content view.
    :param: willDecelerate Default Cocoa API - true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
    */
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isHidingEnabled {
            if let navigationCtr = self.navigationController {
                if ((navigationCtr.navigationBar.frame.origin.y != 20 || navigationCtr.navigationBar.frame.origin.y != -24) && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                    
                    if (self.scrollDirection == .Down) {
                        // hide

                        var statusBarBackgroundViewFrame = self.statusBarBackgroundView?.frame
                        var barFrame = navigationCtr.navigationBar.frame;
                        var blackstripe = self.createMinifiedStripeBar(navigationCtr)
                        
                        statusBarBackgroundViewFrame?.origin.y = -44
                        barFrame.origin.y = -24
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            blackstripe.hidden = false
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
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.isHidingEnabled {
            if let navigationCtr = self.navigationController {
                if (self.isViewLoaded() && self.view.window != nil && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                    // check when refresher is refreshing
                    if (self.automaticSnapStatus == .None) {
                        if (self.lastScrollViewContentOffset > scrollView.contentOffset.y) {
                            self.scrollDirection = .Up
                            
                            if scrollView.contentSize.height - 1 < scrollView.contentOffset.y + scrollView.frame.size.height {
                                self.automaticSnapStatus == .WillSnap
                            } else {
                                // show
                                // legacy code : && !(568 >= scrollView.contentSize.height - scrollView.contentOffset.y)
                                
                                if (!(scrollView.contentOffset.y < -64.0)) {
                                    var statusBarBackgroundViewFrame = self.statusBarBackgroundView?.frame
                                    var barFrame = navigationCtr.navigationBar.frame
                                    
                                    if (barFrame.origin.y <= 19) {
                                        if let blackstripe = navigationCtr.view.viewWithTag(5555) {
                                            blackstripe.removeFromSuperview()
                                        }
                                        
                                        let toMove = self.lastScrollViewContentOffset - scrollView.contentOffset.y
                                        if (barFrame.origin.y + toMove < 20) {
                                            statusBarBackgroundViewFrame?.origin.y += toMove
                                            barFrame.origin.y += toMove
                                        } else {
                                            statusBarBackgroundViewFrame?.origin.y = 0;
                                            barFrame.origin.y = 20;
                                        }
                                        
                                        self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                                        navigationCtr.navigationBar.frame = barFrame
                                    } else {
                                        statusBarBackgroundViewFrame?.origin.y = 0;
                                        self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                                        
                                        barFrame.origin.y = 20;
                                        navigationCtr.navigationBar.frame = barFrame
                                    }
                                }
                            }
                        } else if (self.lastScrollViewContentOffset < scrollView.contentOffset.y) {
                            self.scrollDirection = .Down
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
                                        var blackstripe = self.createMinifiedStripeBar(navigationCtr)
                                        statusBarBackgroundViewFrame?.origin.y = -44;
                                        barFrame.origin.y = -24;
                                    }
                                    self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                                    navigationCtr.navigationBar.frame = barFrame
                                }
                            }
                            
                            if let ref = scrollView.viewWithTag(T2GViewTags.refreshControl) {
                                if !CGRectContainsRect(scrollView.bounds, ref.bounds) {
                                    scrollHandler()
                                }
                            } else {
                                scrollHandler()
                            }
                        }
                        self.lastScrollViewContentOffset = scrollView.contentOffset.y
                    } else {
                        if(scrollView.contentOffset.y == -64) {
                            if (self.automaticSnapStatus == .WillSnap) {
                                self.automaticSnapStatus = .DidSnap
                            } else {
                                self.automaticSnapStatus = .None
                                self.handleSnapBack()
                            }
                        }
                    }
                } else {
                    self.scrollDirection = self.lastScrollViewContentOffset > scrollView.contentOffset.y ? .Up : .Down
                    self.lastScrollViewContentOffset = scrollView.contentOffset.y
                }
            }
        } else {
            self.scrollDirection = self.lastScrollViewContentOffset > scrollView.contentOffset.y ? .Up : .Down
            self.lastScrollViewContentOffset = scrollView.contentOffset.y
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
    func createMinifiedStripeBar(navigationCtr: UINavigationController) -> UIView {
        if let blackstripe = navigationCtr.view.viewWithTag(5555) {
            return blackstripe
        } else {
            var blackstripe2 = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 20))
            blackstripe2.tag = 5555
            blackstripe2.backgroundColor = statusBarBackgroundViewColor
            blackstripe2.hidden = true
            navigationCtr.view.addSubview(blackstripe2)
            return blackstripe2
        }
    }
    
    /**
    Helper method to show the bar whatever is going on. Comes in handy when the device is about to be rotated or new view controller is about to be pushed on the stack.
    
    :param: isLandscape Flag determining which kind of navigation bar we'll be dealing with (minified version since iOS 8).
    */
    func showBar(isLandscape: Bool) {
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
