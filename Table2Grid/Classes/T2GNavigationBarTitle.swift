//
//  T2GNavigationBarTitle.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 06/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Custom class for title view in navigation bar. Extends T2GColoredButton so it gives the possibility to either highlight text on click or background.
*/
public class T2GNavigationBarTitle: T2GColoredButton {
    var normalTextColor: UIColor? {
        didSet {
            self.setTitleColor(self.normalTextColor, forState: UIControlState.Normal)
        }
    }
    
    var highlightedTextColor: UIColor? {
        didSet {
            self.setTitleColor(self.highlightedTextColor, forState: UIControlState.Selected)
            self.setTitleColor(self.highlightedTextColor, forState: UIControlState.Highlighted)
        }
    }
    
    /// set-only via initializer
    private var shouldHighlightText = true
    
    /**
    Convenience initializer that creates the whole view. Truncates the text in the middle if it exceeds given width and appends ▾ symbol at the end to inform user that this, in fact, is clickable.
    
    :param: frame CGRect giving the bounds of the button.
    :param: text The text that will be placed as the title. Truncated in the middle if too long.
    :param: shouldHighlightText Determines whether the button should highlight the text or the background.
    */
    public convenience init(frame: CGRect, text: String, shouldHighlightText: Bool) {
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
        self.normalTextColor = .whiteColor()
        self.setTitleColor(self.normalTextColor, forState: UIControlState.Normal)
        
        if self.shouldHighlightText {
            self.highlightedTextColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            self.setTitleColor(self.highlightedTextColor, forState: UIControlState.Selected)
            self.setTitleColor(self.highlightedTextColor, forState: UIControlState.Highlighted)
        } else {
            self.highlightedBackgroundColor = self.highlightedTextColor
        }
    }
    
    /**
    Truncates given string if it is too long to fit in the given frame using given font.
    
    :param: string The text that is supposed to be truncated if necessary.
    :param: width Max width bounding the size of the label.
    :param: font Font for which the size is supposed to be calculated.
    :returns: Truncated string with '...' in the middle.
    */
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
        
        return truncatedString as String
    }

}
