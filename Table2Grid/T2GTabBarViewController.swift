//
//  T2GTabBarViewController.swift
//  TabSplitView
//
//  Created by Michal Švácha on 30/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom TabBar Controller implementing sliding strip on tab controller that slides when tab has been changed.
*/
class T2GTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    /// the sliding strip
    var slidingView: UIView?
    var sliderColor = UIColor.blackColor()

    /**
    Sets the tab bar delegate to be self.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    It is safer to add the sliding view after the subviews have been laid out.
    */
    override func viewDidLayoutSubviews() {
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
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let slider = self.slidingView {
            slider.frame = self.sliderFrameForIndex(self.selectedIndex, barWidth: size.width)
        }
    }
    
    /**
    Slides the sliding view above the selected item in the tab bar.
    
    :param: tabBarController Default Cocoa API - The tab bar controller containing viewController.
    :param: viewController Default Cocoa API - The view controller that the user selected.
    */
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if let slider = self.slidingView {
                slider.frame = self.sliderFrameForIndex(self.selectedIndex, barWidth: self.view.frame.size.width)
            }
        })
    }
    
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let from = find(tabBarController.viewControllers! as [UIViewController], fromVC)
        let to = find(tabBarController.viewControllers! as [UIViewController], toVC)
        var animatedTransitioningObject = T2GTabBarTransition(viewSize: fromVC.view.frame.size, isScrollingLeft: to > from)
        
        return animatedTransitioningObject
    }
    
    /**
    Calculates the exact size and coordinates for the sliding view. It could calculate the x coordinate based only on selected index and current bar state, but that wouldn't make it usable for all the functions that "will...".
    
    :param: index Index for which the x coordinate should be calculated.
    :param: barWidth The width of the bar from which the proportional size is calculated.
    :returns: CGRect frame with all necessary values.
    */
    func sliderFrameForIndex(index: Int, barWidth: CGFloat) -> CGRect {
        let totalSliderWidth = barWidth / CGFloat(self.viewControllers!.count)
        let decreasedWidth = totalSliderWidth * CGFloat(0.8)
        let offsetX = (totalSliderWidth - decreasedWidth) / CGFloat(2.0)
        let x = (totalSliderWidth * CGFloat(index)) + offsetX
        
        return CGRectMake(x, 0.0, decreasedWidth, 3.0)
    }
}
