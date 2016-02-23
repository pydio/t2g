//
//  T2GTriangleView.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 05/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom UIView class for animating triangle while animating the appearance of the navigation bar menu.
*/
class DownTriangleView: UIView {
    
    var color = UIColor.grayColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        self.backgroundColor = UIColor.clearColor()
        
        let layerHeight = self.layer.frame.height
        let layerWidth = self.layer.frame.width
        
        let line = UIBezierPath()
        line.moveToPoint(CGPointMake(0, 0))
        line.addLineToPoint(CGPointMake(layerWidth, 0))
        line.addLineToPoint(CGPointMake(layerWidth/2, layerHeight))
        line.addLineToPoint(CGPointMake(0, 0))
        line.closePath()
        
        color.setStroke()
        color.setFill()
        line.lineWidth = 3.00
        line.fill()
        line.stroke()
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = line.CGPath
        self.layer.mask = shapeLayer
    }
}


class T2GBookmarkTriangleView: UIView {
    var color = UIColor(named: .PYDBlue) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        self.backgroundColor = UIColor.clearColor()
        
        
        let layerHeight = self.layer.frame.height
        let layerWidth = self.layer.frame.width
        
        let line = UIBezierPath()
        line.moveToPoint(CGPointMake(0, 0))
        line.addLineToPoint(CGPointMake(0, layerHeight))
        line.addLineToPoint(CGPointMake(layerWidth, layerHeight))
        line.addLineToPoint(CGPointMake(0, 0))
        line.closePath()
        
        color.setStroke()
        color.setFill()
        line.lineWidth = 3.00
        line.fill()
        line.stroke()
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = line.CGPath
        self.layer.mask = shapeLayer
    }
}

class T2GShareTriangleView: UIView {
    var color = UIColor(named: .PYDMarine) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        self.backgroundColor = UIColor.clearColor()
        
        
        let layerHeight = self.layer.frame.height
        let layerWidth = self.layer.frame.width
        
        let line = UIBezierPath()
        line.moveToPoint(CGPointMake(0, 0))
        line.addLineToPoint(CGPointMake(0, layerHeight))
        line.addLineToPoint(CGPointMake(layerWidth, 0))
        line.addLineToPoint(CGPointMake(0, 0))
        line.closePath()
        
        color.setStroke()
        color.setFill()
        line.lineWidth = 3.00
        line.fill()
        line.stroke()
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = line.CGPath
        self.layer.mask = shapeLayer
    }
}
