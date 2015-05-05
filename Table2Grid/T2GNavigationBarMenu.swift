//
//  T2GNavigationBarMenu.swift
//  TabSplitView
//
//  Created by Michal Švácha on 04/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

protocol T2GNavigationBarMenuDelegate {
    func didSelectButton(index: Int)
}

class T2GNavigationBarMenu: UIView {
    var delegate: T2GNavigationBarMenuDelegate?
    var maxCount: Int = 0
    var setCount: Int = 0
    
    convenience init(frame: CGRect, itemCount: Int) {
        self.init(frame: frame)
        
        self.maxCount = itemCount
        let itemHeight = frame.size.height / CGFloat(itemCount)
        
        for index in 0..<itemCount {
            let y = CGFloat(index) * itemHeight
            let view = T2GColoredButton(frame: CGRectMake(0, y, frame.size.width, itemHeight))
            view.normalBackgroundColor = .clearColor()
            view.highlightedBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            view.tag = index
            view.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(view)
            
            if index + 1 < itemCount {
                let offset: CGFloat = 30.0
                let line = UIView(frame: CGRectMake(offset, view.frame.origin.y + view.frame.size.height, view.frame.size.width - offset, 1))
                line.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
                self.addSubview(line)
            }
        }
    }
    
    func buttonClicked(sender: T2GColoredButton) {
        self.delegate?.didSelectButton(sender.tag)
    }
}
