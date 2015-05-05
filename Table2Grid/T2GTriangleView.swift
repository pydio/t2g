//
//  T2GTriangleView.swift
//  TabSplitView
//
//  Created by Michal Švácha on 05/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
*/
class T2GTriangleView: UIView {

    ///
    var shapeLayer:CAShapeLayer! {
        return self.layer as CAShapeLayer
    }
    
    ///
    override class func layerClass() -> AnyClass {
        return TriangleShapeLayer.self
    }
    
    ///
    override var backgroundColor: UIColor? {
        get {
            return UIColor(CGColor : shapeLayer.fillColor)
        }
        set {
            shapeLayer.fillColor = newValue!.CGColor
        }
    }
    
    /**
    */
    class TriangleShapeLayer: CAShapeLayer {
        override var bounds : CGRect {
            didSet {
                path = self.shapeForBounds(bounds).CGPath
            }
        }
        
        /**
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
