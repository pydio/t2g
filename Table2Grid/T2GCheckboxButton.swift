//
//  T2GCheckboxButton.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 01/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Base class for checkbox in editing mode (can be overriden).
*/
class T2GCheckboxButton: UIButton {
    let strokeColor = UIColor(red: CGFloat(252.0/255.0), green: CGFloat(112.0/255.0), blue: CGFloat(87.0/255.0), alpha: 1.0)
    var isSelected: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /**
    Custom draws the button based on property isSelected.
    
    :param: rect Default Cocoa API - The portion of the view’s bounds that needs to be updated.
    */
    override func drawRect(rect: CGRect) {
        let lineWidth: CGFloat = self.isSelected ? 4.0 : 3.0
        let fillColor = self.isSelected ? UIColor.blackColor().CGColor : UIColor.clearColor().CGColor
        
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, lineWidth)
        CGContextAddArc(context, frame.size.width / 2, frame.size.height / 2, (frame.size.width - 10)/2, 0.0, CGFloat(M_PI * 2.0), 1)
        CGContextSetFillColorWithColor(context, fillColor)
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor)
        CGContextDrawPath(context, kCGPathFillStroke)
    }
    
    /**
    Overriden initializer that serves for setting up initial background color.
    
    :param: frame Default Cocoa API - The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
