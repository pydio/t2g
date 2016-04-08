//
//  T2GUtilities.swift
//  Pydio
//
//  Created by Michal Švácha on 21/07/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
UIColor extension supporting Name declaration in order to prevent tedious RGB initialization.
*/
extension UIColor {
    
    /**
    Enum values of additional colors.
    */
    enum Name: UInt32 {
        case PYDOrange = 0xfc7057ff
        case PYDBlue = 0x79b9e0ff
        case PYDMarine = 0x4aceb0ff
        case PYDLightGray = 0xeaeaeaff
        case PYDTransparentBlack = 0x00000088
    }
    
    /**
    Convenience initializer to initialize color with given Name.
    
    - parameter name: Name Enum representing one of the additional colors.
    */
    convenience init(named name: Name) {
        let RGBAValue = name.rawValue
        let R = CGFloat((RGBAValue >> 24) & 0xff) / 255.0
        let G = CGFloat((RGBAValue >> 16) & 0xff) / 255.0
        let B = CGFloat((RGBAValue >> 8) & 0xff) / 255.0
        let alpha = CGFloat((RGBAValue) & 0xff) / 255.0
        
        self.init(red: R, green: G, blue: B, alpha: alpha)
    }
}