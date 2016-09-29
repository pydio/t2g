//
//  T2GTabBarViewController.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 30/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/**
Custom TabBar Controller implementing sliding strip on tab controller that slides when tab has been changed.
*/
open class T2GTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    /// the sliding strip
    var slidingView: UIView?
    open var sliderColor = UIColor.black

    /**
    Sets the tab bar delegate to be self.
    */
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    It is safer to add the sliding view after the subviews have been laid out.
    */
    override open func viewDidLayoutSubviews() {
        if slidingView == nil {
            self.slidingView = UIView(frame: self.sliderFrameForIndex(self.selectedIndex, barWidth: self.view.frame.size.width))
            self.slidingView!.backgroundColor = self.sliderColor
            self.tabBar.addSubview(self.slidingView!)
        }
    }
    
    /**
    Gets called instead of didRotateFromInterfaceOrientation. Makes sure the frame of the sliding view is proportional to the tab bar's size.
    
    :param: size Default Cocoa API - The new size for the container’s view.
    :param: coordinator Default Cocoa API - The transition coordinator object managing the size change.
    */
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            if let slider = self.slidingView {
                slider.frame = self.sliderFrameForIndex(self.selectedIndex, barWidth: size.width)
            }
            
            /*
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            switch orientation {
            case .Portrait:
                // portrait
                break
            default:
                // else
                break
            }
            */
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            // rotation done
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    /**
    Slides the sliding view above the selected item in the tab bar.
    
    :param: tabBarController Default Cocoa API - The tab bar controller containing viewController.
    :param: viewController Default Cocoa API - The view controller that the user selected.
    */
    open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if let slider = self.slidingView {
                slider.frame = self.sliderFrameForIndex(self.selectedIndex, barWidth: self.view.frame.size.width)
            }
        })
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        let from = tabBarController.viewControllers!.index(of: fromVC)
        let to = tabBarController.viewControllers!.index(of: toVC)
        let animatedTransitioningObject = T2GTabBarTransition(viewSize: fromVC.view.frame.size, isScrollingLeft: to > from)
                
        return animatedTransitioningObject
    }
    
    /**
    Calculates the exact size and coordinates for the sliding view. It could calculate the x coordinate based only on selected index and current bar state, but that wouldn't make it usable for all the functions that "will...".
    
    :param: index Index for which the x coordinate should be calculated.
    :param: barWidth The width of the bar from which the proportional size is calculated.
    :returns: CGRect frame with all necessary values.
    */
    func sliderFrameForIndex(_ index: Int, barWidth: CGFloat) -> CGRect {
        let totalSliderWidth = barWidth / CGFloat(self.viewControllers!.count)
        let decreasedWidth = totalSliderWidth * CGFloat(0.8)
        let offsetX = (totalSliderWidth - decreasedWidth) / CGFloat(2.0)
        let x = (totalSliderWidth * CGFloat(index)) + offsetX
        
        return CGRect(x: x, y: 0.0, width: decreasedWidth, height: 3.0)
    }
}
