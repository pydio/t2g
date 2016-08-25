//
//  T2GCellButton.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 24/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Base class for drawer buttons (can be overriden). Implements resizing based on how much the scrollView in T2GCell is opened.
*/
public class T2GCellDrawerButton: T2GColoredButton {
    public var handler: (Void->Void)?
    public var minOriginCoord: CGPoint?
    public var maxOriginCoord: CGPoint? {
        get {
            return CGPointMake(minOriginCoord!.x - (minSize! / 2), minOriginCoord!.y - (minSize! / 2))
        }
    }
    
    var minSize: CGFloat?
    var maxSize: CGFloat? {
        get {
            return 2 * minSize!
        }
    }
    
    /**
    Overriden initializer that serves for setting up initial values of minSize and minOriginCoord (that serves for calculated property maxOriginCoord).
    
    :param: frame Default Cocoa API - The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.minSize = frame.size.width
        self.minOriginCoord = frame.origin
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
    Resizes the button while scrollView is scrolling. Increases size while going left on the X axis and decreases while going right.
    
    :param: tailPosition The X coordinate of the tip of the tail of the T2GCell that is being scrolled.
    :param: sizeDifference The difference of how much it moved since this method has been called last time. The method automatically adjusts if the value is out of bounds.
    */
    func resize(tailPosition: CGFloat, sizeDifference: CGFloat) {
        let size = self.frame.size.width
        
        /// The '+ (size - 4)' is there because in case the tail is moving left, then the button is smaller and we want it to start getting bigger a brief moment before it actually appears.
        let didBeginOverlapping = tailPosition < self.frame.origin.x + (size - 4)
        let isStillOverlapping = tailPosition > self.frame.origin.x
        
        if didBeginOverlapping && isStillOverlapping {
            var newSize = size + sizeDifference
            var newX = self.frame.origin.x - (sizeDifference / 2)
            var newY = self.frame.origin.y - (sizeDifference / 2)
            
            if newSize > self.maxSize {
                newX = self.maxOriginCoord!.x
                newY = self.maxOriginCoord!.y
                newSize = self.maxSize!
            } else if newSize < self.minSize {
                newX = self.minOriginCoord!.x
                newY = self.minOriginCoord!.y
                newSize = self.minSize!
            }
            
            self.frame = CGRectMake(newX, newY, newSize, newSize)
        } else {
            let isFarOut = tailPosition < self.frame.origin.x
            if isFarOut && size < self.maxSize {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.frame = CGRectMake(self.maxOriginCoord!.x, self.maxOriginCoord!.y, self.maxSize!, self.maxSize!)
                })
            }
            
            let isFarOverlapped = tailPosition > self.frame.origin.x + size
            if isFarOverlapped && size > self.minSize {
                self.frame = CGRectMake(self.minOriginCoord!.x, self.minOriginCoord!.y, self.minSize!, self.minSize!)
            }
        }
    }    
}
