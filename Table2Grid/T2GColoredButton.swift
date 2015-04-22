//
//  T2GColoredButton.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 10/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom implementation of button that changes its background color on tap rather than just the title color.
*/
class T2GColoredButton: UIButton {
    var normalBackgroundColor: UIColor? {
        didSet {
            self.backgroundColor = normalBackgroundColor!
        }
    }
    var highlightedBackgroundColor: UIColor? {
        didSet {
            self.setBackgroundImage(self.imageWithColor(self.highlightedBackgroundColor!), forState: UIControlState.Highlighted)
        }
    }
    
    /**
    Creates background image to be set as a background for highlighted state.
    
    - DISCUSSION: This class used to be implemented with three listeners on TouchUpInside, TouchUpOutside and TouchDown that would change the background color. The problem was that it wasn't fast enough (slight, but still noticeable delay). This implementation may not be "standard" but it sure solves the whole issue very well.
    
    :param: color Color to be used to fill the image with.
    :returns: UIImage with the same dimensions as this view filled with given color.
    */
    func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()
    
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
    
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return image
    }
}
