//
//  T2GStyle.swift
//  Pydio
//
//  Created by Leo Marcotte on 13/04/16.
//  Copyright © 2016 Leo Marcotte. All rights reserved.
//

import Foundation
import UIKit

public struct T2GStyle {

    public struct Node {
        public static var nodeTitleColor = UIColor.blackColor()
        public static var nodeTitleFont = UIFont(name: "SFUIDisplay-Regular", size: 16)
        
        public static var nodeDescriptionColor = UIColor.grayColor()
        public static var nodeDescriptionFont = UIFont(name: "SFUIDisplay-Light", size: 13)
        
        public static var nodeIconViewBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.02)
        public static var nodeImageViewTintColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1.0)
        public static var nodeBackgroundViewBackgroundColor = UIColor.whiteColor()
        public static var nodeScrollViewBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.02)
        

        
        
        
        public struct Collection {
            public static var backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04)
            public static var whiteFooterBackgroundColor = UIColor.whiteColor()
        }
        
        public struct Table {
            public static var backgroundColor = UIColor(red: 0.995, green: 0.995, blue: 0.995, alpha: 1)
        }
        
    }
}
