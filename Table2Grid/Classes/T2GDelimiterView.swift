//
//  T2GDelimiterView.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 20/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Base class for delimiters in T2GScrollView (can be overriden).
*/
class T2GDelimiterView: UIView {
    var titleLabel: UILabel?
    
    /**
    Convenience initializer to initialize the delimiter with given parameters.
    
    :param: title Text line.
    :param: frame Frame for the delimiter.
    */
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        
        self.titleLabel = UILabel()
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleLabel!.textColor = .gray
        self.titleLabel!.text = title
        self.addSubview(self.titleLabel!)
        
        self.titleLabel!.translatesAutoresizingMaskIntoConstraints = false
        let views = ["background": self, "button": self.titleLabel!] as [String : Any]
        
        let constH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: .alignAllCenterY, metrics: nil, views: views)
        self.addConstraints(constH)
        
        let constW = NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: .alignAllCenterX, metrics: nil, views: views)
        self.addConstraints(constW)
    }
    
    /**
    Calculates proportional max size of font for a label in given frame.
    
    :param: frame Bounds for the text used for the calculation.
    :returns: Max size of system font.
    */
    fileprivate func fontSize(_ frame: CGRect) -> CGFloat {
        let dummyString: NSString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        let dummyFont = UIFont.systemFont(ofSize: 12)
        
        let size = dummyString.size(attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 12)])
        let adjustedSize: CGSize = CGSize(width: CGFloat(ceilf(Float(size.width))), height: CGFloat(ceilf(Float(size.height))))
        
        let pointsPerPixel = dummyFont.pointSize / adjustedSize.height
        return frame.size.height * pointsPerPixel
    }
}
