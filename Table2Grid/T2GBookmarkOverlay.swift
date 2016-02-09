//
//  T2GBookmarkOverlay.swift
//  Pydio
//
//  Created by Michal Švácha on 08/09/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom T2GTriangleView subclass to draw triangle arrow facing south-west.
*/

class T2GBookmarkOverlay: T2GTriangleView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: .PYDBlue)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class func layerClass() -> AnyClass {
        return self//BookmarkLayer.self
    }
    
//    class BookmarkLayer: TriangleLayer {
//        override func shapeForBounds(rect: CGRect) -> UIBezierPath {
//            let point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
//            let point2 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
//            let point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
//            
//            let triangle = UIBezierPath()
//            triangle.moveToPoint(point1)
//            triangle.addLineToPoint(point2)
//            triangle.addLineToPoint(point3)
//            triangle.closePath()
//            return triangle
//        }
//    }
}
