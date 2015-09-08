//
//  T2GShareOverlay.swift
//  Pydio
//
//  Created by Michal Švácha on 08/09/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom T2GTriangleView subclass to draw triangle arrow facing north-west.
*/
class T2GShareOverlay: T2GBookmarkOverlay {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: .PYDMarine)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func layerClass() -> AnyClass {
        return ShareLayer.self
    }
    
    class ShareLayer: BookmarkLayer {
        override func shapeForBounds(rect: CGRect) -> UIBezierPath {
            let point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
            let point2 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
            let point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
            
            let triangle = UIBezierPath()
            triangle.moveToPoint(point1)
            triangle.addLineToPoint(point2)
            triangle.addLineToPoint(point3)
            triangle.closePath()
            return triangle
        }
    }
}