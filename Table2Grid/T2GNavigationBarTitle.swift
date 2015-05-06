//
//  T2GNavigationBarTitle.swift
//  TabSplitView
//
//  Created by Michal Švácha on 06/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**

*/
class T2GNavigationBarTitle: T2GColoredButton {
    var normalTextColor: UIColor = .whiteColor()
    var highlightedTextColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
    private var shouldHighlightText = true
    
    /**
    
    
    :param: frame
    :param: text
    */
    convenience init(frame: CGRect, text: String, shouldHighlightText: Bool) {
        self.init(frame: frame)
        self.shouldHighlightText = shouldHighlightText

        let triangleWidth = CGFloat(9.0)
        let triangleMargin = CGFloat(3.0)
        
        let labelSize = text.sizeWithAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(17.0)])
        let maxWidth = frame.size.width - triangleWidth - triangleMargin
        let actualLabelWidth = labelSize.width < maxWidth ? labelSize.width : maxWidth
        
        let title = "\(self.stringTruncatedToWidth(text, width: actualLabelWidth, font: UIFont.boldSystemFontOfSize(17.0))) ▾" //▼"
        self.setTitle(title, forState: UIControlState.Normal)
        self.titleLabel!.font = UIFont.boldSystemFontOfSize(17.0)
        
        if self.shouldHighlightText {
            self.setTitleColor(self.normalTextColor, forState: UIControlState.Normal)
            self.setTitleColor(self.highlightedTextColor, forState: UIControlState.Selected)
            self.setTitleColor(self.highlightedTextColor, forState: UIControlState.Highlighted)
        } else {
            self.highlightedBackgroundColor = self.highlightedTextColor
        }
    }
    
    func stringTruncatedToWidth(string: NSString, width: CGFloat, font: UIFont) -> String {
        var truncatedString = NSMutableString(string: string)

        var newWidth = width
        
        if (string.sizeWithAttributes([NSFontAttributeName : font]).width > newWidth) {
            newWidth -= "...".sizeWithAttributes([NSFontAttributeName:font]).width
            
            let range = NSMakeRange(0, 1)
            while (truncatedString.sizeWithAttributes([NSFontAttributeName:font]).width > newWidth) {
                truncatedString.deleteCharactersInRange(range)
            }
            
            truncatedString = NSMutableString(string: "\(string.substringToIndex(truncatedString.length/2))...\(string.substringFromIndex(string.length - truncatedString.length/2))")
        }
        
        return truncatedString
    }

}
