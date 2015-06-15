//
//  MasterViewController.swift
//  TabSplitView - T2G Example
//
//  Created by Michal Švácha on 30/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom MasterView controller for SplitView controller. Subclass of custom UITabBar controller. Contains other view controllers embeded in custom UINavigation controllers.
*/
class MasterViewController: T2GTabBarViewController {

    var detailViewController: DetailViewController? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sliderColor = UIColor(red: CGFloat(252.0/255.0), green: CGFloat(112.0/255.0), blue: CGFloat(87.0/255.0), alpha: 1.0)
        self.tabBar.translucent = false
        self.tabBar.backgroundColor = .whiteColor()
        self.tabBar.selectedImageTintColor = UIColor(red: CGFloat(252.0/255.0), green: CGFloat(112.0/255.0), blue: CGFloat(87.0/255.0), alpha: 1.0)
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = NSDate()
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

