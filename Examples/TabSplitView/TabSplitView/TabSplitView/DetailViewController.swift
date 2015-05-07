//
//  DetailViewController.swift
//  TabSplitView - T2G Example
//
//  Created by Michal Švácha on 30/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom DetailView controller.
*/
class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var statusBarBackgroundViewColor = UIColor(red: CGFloat(252.0/255.0), green: CGFloat(112.0/255.0), blue: CGFloat(87.0/255.0), alpha: 1.0)

    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        if let navigationCtr = self.navigationController {
            navigationCtr.navigationBar.barTintColor = self.statusBarBackgroundViewColor
            navigationCtr.navigationBar.tintColor = .whiteColor()
            
            navigationCtr.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName : UIColor.whiteColor()
            ]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

