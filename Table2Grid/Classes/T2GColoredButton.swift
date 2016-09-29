//
//  T2GColoredButton.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 10/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom implementation of button that changes its background color on tap rather than just the title color.
*/
open class T2GColoredButton: UIButton {
    var normalBackgroundColor: UIColor? {
        didSet {
            self.backgroundColor = normalBackgroundColor!
        }
    }
    
    var highlightedBackgroundColor: UIColor? {
        didSet {
            self.setBackgroundImage(self.imageWithColor(self.highlightedBackgroundColor!), for: UIControlState.highlighted)
        }
    }
    
    /**
    Creates an image based on a color to be used for example as a background for certain state.
    
    - DISCUSSION: This class used to be implemented with three listeners on TouchUpInside, TouchUpOutside and TouchDown that would change the background color. The problem was that it wasn't fast enough (slight, but still noticeable delay). This implementation may not be "standard" but it sure solves the whole issue very well.
    
    :param: color Color to be used to fill the image with.
    :returns: UIImage with the same dimensions as this view filled with given color.
    */
    fileprivate func imageWithColor(_ color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
    
        context.setFillColor(color.cgColor)
        context.fill(rect)
    
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /**
    Creates an image based on a view to be used for example as a background for certain state.
    
    - WARNING: The view must be rendered already. Without it, it creates a UIImage that is completely black.
    
    :param: view View that will be transformed into a UIImage.
    :returns: UIImage of the same size as the view given in the parameter.
    */
    func imageWithView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        
       let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
