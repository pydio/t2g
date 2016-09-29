//
//  T2GNavigationBarTitle.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 06/05/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit
import Material

/**
Custom class for title view in navigation bar. Extends T2GColoredButton so it gives the possibility to either highlight text on click or background.
*/
open class T2GNavigationBarTitle: T2GColoredButton {
    open var normalTextColor: UIColor? {
        didSet {
            self.setTitleColor(self.normalTextColor, for: UIControlState())
        }
    }
    
    var highlightedTextColor: UIColor? {
        didSet {
            self.setTitleColor(self.highlightedTextColor, for: UIControlState.selected)
            self.setTitleColor(self.highlightedTextColor, for: UIControlState.highlighted)
        }
    }
    
    /// set-only via initializer
    fileprivate var shouldHighlightText = true
    
    /**
    Convenience initializer that creates the whole view. Truncates the text in the middle if it exceeds given width and appends ▾ symbol at the end to inform user that this, in fact, is clickable.
    
    :param: frame CGRect giving the bounds of the button.
    :param: text The text that will be placed as the title. Truncated in the middle if too long.
    :param: shouldHighlightText Determines whether the button should highlight the text or the background.
    */
    public convenience init(frame: CGRect, text: String, color: UIColor) {
        self.init(frame: frame)

        let triangleWidth = CGFloat(9.0)
        let triangleMargin = CGFloat(3.0)
        
        let labelSize = text.size(attributes: [NSFontAttributeName : RobotoFont.medium(with: 20)])
        let maxWidth = frame.size.width - triangleWidth - triangleMargin
        let actualLabelWidth = labelSize.width < maxWidth ? labelSize.width : maxWidth
        
        let title = "\(self.stringTruncatedToWidth(text as NSString, width: actualLabelWidth, font: RobotoFont.medium(with: 20))) ▾"
        setTitle(title, for: UIControlState())
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 17.0)
        normalTextColor = color
        setTitleColor(self.normalTextColor, for: UIControlState())
        
        highlightedTextColor = color.withAlphaComponent(0.3)
        setTitleColor(highlightedTextColor, for: UIControlState.selected)
        setTitleColor(highlightedTextColor, for: UIControlState.highlighted)
    }
    
    
    /**
    Truncates given string if it is too long to fit in the given frame using given font.
    
    :param: string The text that is supposed to be truncated if necessary.
    :param: width Max width bounding the size of the label.
    :param: font Font for which the size is supposed to be calculated.
    :returns: Truncated string with '...' in the middle.
    */
    func stringTruncatedToWidth(_ string: NSString, width: CGFloat, font: UIFont) -> String {
        var truncatedString = NSMutableString(string: string)
        var newWidth = width
        
        if (string.size(attributes: [NSFontAttributeName : font]).width > newWidth) {
            newWidth -= "...".size(attributes: [NSFontAttributeName:font]).width
            
            let range = NSMakeRange(0, 1)
            while (truncatedString.size(attributes: [NSFontAttributeName:font]).width > newWidth) {
                truncatedString.deleteCharacters(in: range)
            }
            
            truncatedString = NSMutableString(string: "\(string.substring(to: truncatedString.length/2))...\(string.substring(from: string.length - truncatedString.length/2))")
        }
        
        return truncatedString as String
    }

}
