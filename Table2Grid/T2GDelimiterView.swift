//
//  T2GDelimiterView.swift
//  SplitView
//
//  Created by Michal Švácha on 20/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class T2GDelimiterView: UIView {
    var titleLabel: UILabel?
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        
        self.backgroundColor = .darkGrayColor()
        
        self.titleLabel = UILabel()
        self.titleLabel!.font = UIFont.boldSystemFontOfSize(15)
        self.titleLabel!.textColor = .whiteColor()
        self.titleLabel!.text = title
        self.addSubview(self.titleLabel!)
        
        self.titleLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = ["background": self, "button": self.titleLabel!]
        
        var constH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[button]|", options: .AlignAllCenterY, metrics: nil, views: views)
        self.addConstraints(constH)
        
        var constW = NSLayoutConstraint.constraintsWithVisualFormat("V:|[button]|", options: .AlignAllCenterX, metrics: nil, views: views)
        self.addConstraints(constW)
    }
    
    private func fontSize(frame: CGRect) -> CGFloat {
        let dummyString: NSString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        var dummyFont = UIFont.systemFontOfSize(12)
        
        let size = dummyString.sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(12)])
        let adjustedSize: CGSize = CGSizeMake(CGFloat(ceilf(Float(size.width))), CGFloat(ceilf(Float(size.height))))
        
        let pointsPerPixel = dummyFont.pointSize / size.height
        return frame.size.height * pointsPerPixel
    }
}
