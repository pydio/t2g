//
//  T2GColoredButton.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 10/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class T2GColoredButton: UIButton {
    var normalBackgroundColor: UIColor? {
        didSet {
            self.backgroundColor = normalBackgroundColor!
        }
    }
    var highlightedBackgroundColor: UIColor?
    
    func didTap() {
        self.backgroundColor = self.highlightedBackgroundColor!
    }
    
    func didUntap() {
        self.backgroundColor = self.normalBackgroundColor!
    }
    
    func setup() {
        self.addTarget(self, action: "didTap", forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: "didUntap", forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: "didUntap", forControlEvents: UIControlEvents.TouchUpOutside)
    }
}
