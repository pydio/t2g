//
//  T2GStyle.swift
//  Pydio
//
//  Created by Leo Marcotte on 13/04/16.
//  Copyright © 2016 Leo Marcotte. All rights reserved.
//

import Foundation
import UIKit



struct T2GStyle {

    struct Node {
        static var nodeTitleColor = UIColor.blackColor()
        static var nodeTitleFont = UIFont(name: "SFUIDisplay-Regular", size: 16)
        
        static var nodeDescriptionColor = UIColor.grayColor()
        static var nodeDescriptionFont = UIFont(name: "SFUIDisplay-Light", size: 13)
        
        
        static var nodeIconViewBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.02)
        static var nodeImageViewTintColor = UIColor.darkGrayColor()
    }
    
    struct CopyMoveView {
        static var backgroundColor = UIColor(named: .PYDMarine)
        static var titleFont = UIFont(name: "SFUIDisplay-Light", size: 26)
        static var titleColor = UIColor.whiteColor()
        static var itemFont = UIFont(name: "SFUIDisplay-Regular", size: 15)
        static var itemColor = UIColor.whiteColor()
    }
}
