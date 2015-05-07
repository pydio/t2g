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
class T2GTriangleView: UIView {

    /// overridden property to be able to distribute the change to the fill of the layer
    override var backgroundColor: UIColor? {
        get {
            return UIColor(CGColor: shapeLayer.fillColor)
        }
        set {
            shapeLayer.fillColor = newValue!.CGColor
        }
    }
    
    /// custom calculated property for layer
    var shapeLayer: CAShapeLayer! {
        return self.layer as CAShapeLayer
    }
    
    /**
    Sets custom class of the layer.
    
    :returns: Default Cocoa API - The class used to create the view’s Core Animation layer.
    */
    override class func layerClass() -> AnyClass {
        return TriangleLayer.self
    }
    
    //MARK: -
    /**
    Custom private shape layer class for animating the triangle with smooth transition.
    */
    class TriangleLayer: CAShapeLayer {
        override var bounds: CGRect {
            didSet {
                path = self.shapeForBounds(bounds).CGPath
            }
        }
        
        /**
        Creates the triangle shape for given rectangle. Created triangle always points down.
        
        :param: rect CGRect object to define the bounds where the triangle path should be drawn.
        :returns: UIBezierPath defining the path of the triangle.
        */
        func shapeForBounds(rect: CGRect) -> UIBezierPath {
            let point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
            let point2 = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))
            let point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
            
            let triangle = UIBezierPath()
            triangle.moveToPoint(point1)
            triangle.addLineToPoint(point2)
            triangle.addLineToPoint(point3)
            triangle.closePath()
            return triangle
        }
        
        /**
        Overrides default behavior to be able to render the view when the frame gets changed.
        
        :param: anim Default Cocoa API - The animation to be added to the render tree.
        :param: key Default Cocoa API - A string that identifies the animation.
        */
        override func addAnimation(anim: CAAnimation!, forKey key: String!) {
            super.addAnimation(anim, forKey: key)
            
            if (anim.isKindOfClass(CABasicAnimation.self)) {
                let basicAnimation = anim as CABasicAnimation
                if (basicAnimation.keyPath == "bounds.size") {
                    var pathAnimation = basicAnimation.mutableCopy() as CABasicAnimation
                    pathAnimation.keyPath = "path"
                    pathAnimation.fromValue = self.path
                    pathAnimation.toValue = self.shapeForBounds(self.bounds).CGPath
                    self.removeAnimationForKey("path")
                    self.addAnimation(pathAnimation,forKey: "path")
                }
            }
        }
    }
}
