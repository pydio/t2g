//
//  T2GNaviViewController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 13/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class T2GNaviViewController: UINavigationController {
    var segueDelay: Double = 0.0
    var statusBarBackgroundView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addStatusBarBackgroundView() -> UIView {
        if let view = self.view.viewWithTag(T2GViewTags.statusBarBackgroundView.rawValue) {
            return view
        } else {
            let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 20))
            view.tag = T2GViewTags.statusBarBackgroundView.rawValue
            view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07)
            self.view.addSubview(view)
            return view
        }
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        var poppedViewController = super.popViewControllerAnimated(animated)
        if let visibleViewController = self.visibleViewController as? T2GViewController {
            visibleViewController.showBar(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            //visibleViewController.animateSubviewCells(visibleViewController.scrollView, isGoingOffscreen: false)
            visibleViewController.scrollView.animateSubviewCells(false)
        }
        return poppedViewController
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        if let viewController = self.visibleViewController as? T2GViewController {
            viewController.showBar(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            //viewController.animateSubviewCells(viewController.scrollView, isGoingOffscreen: true)
            viewController.scrollView.animateSubviewCells(true)
        }
        
        self.delay(self.segueDelay, closure: { () -> Void in
            self.performPush(viewController, animated: animated)
        })
    }
    
    func performPush(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    func delay(delay: Double, closure:() -> Void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }

}
