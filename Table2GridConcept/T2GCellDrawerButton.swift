//
//  T2GCellButton.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 24/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class T2GCellDrawerButton: T2GColoredButton {
    var minOriginCoord: CGPoint?
    var maxOriginCoord: CGPoint? {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.minSize = frame.size.width
        self.minOriginCoord = frame.origin
    }
    
    override func setup() {
        super.setup()
        self.setTitle("\(self.tag - T2GViewTags.cellDrawerButtonConstant.rawValue + 1)", forState: UIControlState.Normal)
    }
    
    func resize(tailPosition: CGFloat, sizeDifference: CGFloat) {
        let size = self.frame.size.width
        
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
