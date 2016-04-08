//
//  T2GDrawerScrollView.swift
//  Pydio
//
//  Created by Michal Švácha on 29/07/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom UIScrollView to speed up touch up inside events in the T2GCell.
*/
class T2GCellDrawerScrollView: UIScrollView {
    
    /**
    Helps not to delay the touchUpInside event on a UIButton that could possibly be a subview.
    
    - DISCUSSION: referenced from: http://stackoverflow.com/questions/3642547/uibutton-touch-is-delayed-when-in-uiscrollview
    */
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view is T2GColoredButton || view is T2GCellDrawerButton {
            return true
        }
        
        return  super.touchesShouldCancelInContentView(view)
    }
}
