//
//  T2GCheckboxButton.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 01/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class T2GCheckboxButton: UIButton {
    let strokeColor = UIColor(red: CGFloat(252.0/255.0), green: CGFloat(112.0/255.0), blue: CGFloat(87.0/255.0), alpha: 1.0)
    var isSelected: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
