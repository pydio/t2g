//
//  T2GNavigationBarTitle.swift
//  TabSplitView
//
//  Created by Michal Švácha on 06/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class T2GNavigationBarTitle: T2GColoredButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init(frame: CGRect, text: String) {
        self.init(frame: frame)
        
        let triangleWidth = CGFloat(9.0)
        let edgeInset = CGFloat(2.0)
        let subviewMargin = CGFloat(3.0)
        let labelSize = text.sizeWithAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(17.0)])
        let maxWidth = frame.size.width - triangleWidth - (CGFloat(2) * edgeInset) - subviewMargin
        let actualLabelWidth = labelSize.width < maxWidth ? labelSize.width : maxWidth
        
        let labelXCoord = (frame.size.width - (actualLabelWidth + subviewMargin + triangleWidth)) / CGFloat(2)
        
        let subview = UIView(frame: frame)
        subview.tag = 3
        
        let triangle = T2GTriangleView(frame:CGRectMake(labelXCoord + actualLabelWidth + subviewMargin, (frame.size.height - 7.0) / CGFloat(2), 9.0, 7.0))
        triangle.tag = 1
        triangle.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        subview.addSubview(triangle)
        
        let label = UILabel(frame: CGRectMake(labelXCoord, (frame.size.height - 20.0) / CGFloat(2), actualLabelWidth, 20.0))
        label.tag = 2
        label.font = UIFont.boldSystemFontOfSize(17.0)
        label.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        label.text = text
        label.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        subview.addSubview(label)
        
        subview.userInteractionEnabled = false
        subview.exclusiveTouch = false
        subview.backgroundColor = .clearColor()
        
        self.addSubview(subview)
        
        self.normalBackgroundColor = .clearColor()
    }
    
    func titleViewAdded() {
        if let subview = self.viewWithTag(3) {
            if subview.alpha != 0 {
                let img = self.imageWithView(self)
                self.setBackgroundImage(img, forState: UIControlState.Highlighted)
                
                if let triangle = self.viewWithTag(1) as? T2GTriangleView {
                    triangle.backgroundColor = .whiteColor()
                }
                
                if let label = self.viewWithTag(2) as? UILabel {
                    label.textColor = .whiteColor()
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.setNeedsDisplay()
                    
                    let img2 = self.imageWithView(self)
                    self.setBackgroundImage(img2, forState: UIControlState.Normal)
                    
                    subview.alpha = 0
                })
            }
        }
    }

}
