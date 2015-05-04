//
//  T2GNavigationBarMenu.swift
//  TabSplitView
//
//  Created by Michal Švácha on 04/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class T2GNavigationBarMenu: UIView {
    var maxCount: Int = 0
    var setCount: Int = 0

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init(frame: CGRect, itemCount: Int) {
        self.init(frame: frame)
        
        self.maxCount = itemCount
        let itemHeight = frame.size.height / CGFloat(itemCount)
        
        for index in 0..<itemCount {
            let y = CGFloat(index) * itemHeight
            let view = UIView(frame: CGRectMake(0, y, frame.size.width, itemHeight))
            view.backgroundColor = .blackColor()
            var hue = CGFloat(index) + 0.2
            view.alpha = 1.0 / hue
            self.addSubview(view)
        }   
    }
}
