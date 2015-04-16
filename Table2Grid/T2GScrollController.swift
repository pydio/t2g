//
//  T2GScrollController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 23/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

enum T2GAutomaticScrollViewSnapStatus {
    case None
    case WillSnap
    case DidSnap
    
    init(){
        self = .None
    }
}

enum T2GScrollDirection {
    case Up
    case Down
    
    init(){
        self = .Up
    }
}

class T2GScrollController: UIViewController, UIScrollViewDelegate {
    var isHidingEnabled = true
    var statusBarBackgroundView: UIView?
    var statusBarBackgroundViewColor = UIColor(red: CGFloat(252.0/255.0), green: CGFloat(112.0/255.0), blue: CGFloat(87.0/255.0), alpha: 1.0)
    
    var lastScrollViewContentOffset: CGFloat = 0
    var scrollDirection: T2GScrollDirection = T2GScrollDirection()
    var automaticSnapStatus: T2GAutomaticScrollViewSnapStatus = T2GAutomaticScrollViewSnapStatus()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.showBar(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    }

    //MARK: - Scroll view delegate
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isHidingEnabled {
            if let navigationCtr = self.navigationController {
                if ((navigationCtr.navigationBar.frame.origin.y != 20 || navigationCtr.navigationBar.frame.origin.y != -24) && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                    
                    if (self.scrollDirection == .Down) {
                        // hide

                        var statusBarBackgroundViewFrame = self.statusBarBackgroundView?.frame
                        var barFrame = navigationCtr.navigationBar.frame;
                        var blackstripe = self.dummyStripeBar(navigationCtr)
                        
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
                                        var blackstripe = self.dummyStripeBar(navigationCtr)
                                        statusBarBackgroundViewFrame?.origin.y = -44;
                                        barFrame.origin.y = -24;
                                    }
                                    self.statusBarBackgroundView?.frame = statusBarBackgroundViewFrame!
                                    navigationCtr.navigationBar.frame = barFrame
                                }
                            }
                            
                            if let ref = scrollView.viewWithTag(T2GViewTags.refreshControl.rawValue) {
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
    
    func handleSnapBack() {
        // meant to be overridden
    }
    
    func dummyStripeBar(navigationCtr: UINavigationController) -> UIView {
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
