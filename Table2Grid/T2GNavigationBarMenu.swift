//
//  T2GNavigationBarMenu.swift
//  TabSplitView
//
//  Created by Michal Švácha on 04/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
...
*/
protocol T2GNavigationBarMenuDelegate {
    /**
    ...
    
    :param: index
    :param: size
    :returns:
    */
    func viewForCell(index: Int, size: CGSize) -> UIView
    
    /**
    ...
    
    :param: index
    */
    func didSelectButton(index: Int)
}

/**
...
*/
class T2GNavigationBarMenu: UIView {
    var delegate: T2GNavigationBarMenuDelegate?
    var maxCount: Int = 0
    var setCount: Int = 0
    
    /**
    ...
    */
    convenience init(frame: CGRect, itemCount: Int, delegate: T2GNavigationBarMenuDelegate?) {
        self.init(frame: frame)
        
        self.delegate = delegate
        self.maxCount = itemCount
        let itemHeight = frame.size.height / CGFloat(itemCount)
        
        for index in 0..<itemCount {
            let y = CGFloat(index) * itemHeight
            let button = T2GColoredButton(frame: CGRectMake(0, y, frame.size.width, itemHeight))
            button.normalBackgroundColor = .clearColor()
            button.highlightedBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            button.tag = index
            button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(button)
            
            if index + 1 < itemCount {
                let offset: CGFloat = 30.0
                let line = UIView(frame: CGRectMake(offset, button.frame.origin.y + button.frame.size.height, button.frame.size.width - offset, 1))
                line.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
                self.addSubview(line)
            }
        }
    }
    
    /**
    ...
    
    :param: sender
    */
    func buttonClicked(sender: T2GColoredButton) {
        self.delegate?.didSelectButton(sender.tag)
    }
}
