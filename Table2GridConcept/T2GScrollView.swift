//
//  T2GScrollView.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 14/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

protocol T2GScrollViewDelegate {
    func currentLayout() -> T2GLayoutMode
    func cellDimensions(mode: T2GLayoutMode) -> (width: CGFloat, height: CGFloat, padding: CGFloat)
    func cellCount(inSection: Int) -> Int
}

class T2GScrollView: UIScrollView {
    var viewDelegate: T2GScrollViewDelegate?

    //TODO: Calculate the number based on the screen size
    private var visibleCellCount: Int {
        get {
            if self.viewDelegate!.currentLayout() == .Table {
                return 10
            } else {
                return 20
            }
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func animateSubviewCells(isGoingOffscreen: Bool) {
        var delayCount: Double = 0.0
        let xOffset: CGFloat = isGoingOffscreen ? -150 : 150
        
        var tags = self.subviews.map({($0 as UIView).tag})
        tags.sort(isGoingOffscreen ? {$0 > $1} : {$0 < $1})
        
        for tag in tags {
            if let view = self.viewWithTag(tag) as? T2GCell {
                let frame = self.frameForCell(self.viewDelegate!.currentLayout(), index: view.tag - T2GViewTags.cellConstant.rawValue)
                
                if isGoingOffscreen || view.frame.origin.x != frame.origin.x {
                    delayCount += 1.0
                    let delay: Double = delayCount * 0.02
                    UIView.animateWithDuration(0.2, delay: delay, options: nil, animations: { () -> Void in
                        view.frame = CGRectMake(view.frame.origin.x + xOffset, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
                    }, completion: nil)
                }
            }
        }
    }
    
    func frameForCell(mode: T2GLayoutMode, index: Int = 0) -> CGRect {
        let superviewFrame = self.superview!.frame
        let dimensions = self.viewDelegate!.cellDimensions(mode)
        
        if mode == .Collection {
            /// Assuming that the collection is square of course
            let middle = (superviewFrame.size.width - dimensions.width) / 2
            let left = (middle - dimensions.width) / 2
            let right = middle + dimensions.width + left
            var xCoords = [left, middle, right]
            let yCoord = dimensions.padding + (CGFloat(index / xCoords.count) * (dimensions.height + dimensions.padding))
            let frame = CGRectMake(CGFloat(xCoords[index % xCoords.count]), yCoord, dimensions.width, dimensions.height)
            
            return frame
            
        } else {
            let viewX = (superviewFrame.size.width - dimensions.width) / 2
            let ypsilon = viewX + (CGFloat(index) * (dimensions.height + dimensions.padding))
            return CGRectMake(viewX, ypsilon, dimensions.width, dimensions.height)
        }
    }
    
    
    //MARK: - Helper methods
    
    func contentSizeForMode(mode: T2GLayoutMode) -> CGSize {
        let dimensions = self.viewDelegate!.cellDimensions(mode)
        let viewX = mode == .Collection ? dimensions.padding : (self.superview!.frame.size.width - dimensions.width) / 2
        let divisor = mode == .Collection ? 3 : 1
        let lineCount = Int(ceil(Double((self.viewDelegate!.cellCount(0) - 1) / divisor)))
        let ypsilon = viewX + (CGFloat(lineCount) * (dimensions.height + dimensions.padding))
        let height = ypsilon + dimensions.height + dimensions.padding
        
        return CGSize(width: self.superview!.frame.size.width, height: height)
    }
    
    func indicesForVisibleCells(mode: T2GLayoutMode) -> [Int] {
        let frame = self.bounds
        var res = [Int]()
        let dimensions = self.viewDelegate!.cellDimensions(mode)
        
        if mode == .Collection {
            var firstIndex = Int(floor((frame.origin.y - dimensions.height) / (dimensions.height + dimensions.padding))) * 3
            if firstIndex < 0 {
                firstIndex = 0
            }
            
            var lastIndex = firstIndex + 2 * self.visibleCellCount
            if self.viewDelegate!.cellCount(0) - 1 < lastIndex {
                lastIndex = self.viewDelegate!.cellCount(0) - 1
            }
            
            for index in firstIndex...lastIndex {
                res.append(index)
            }
        } else {
            var firstIndex = Int(floor((frame.origin.y - dimensions.height) / (dimensions.height + dimensions.padding)))
            if firstIndex < 0 {
                firstIndex = 0
            }
            
            var lastIndex = firstIndex + self.visibleCellCount
            if self.viewDelegate!.cellCount(0) - 1 < lastIndex {
                lastIndex = self.viewDelegate!.cellCount(0) - 1
            }
            
            for index in firstIndex...lastIndex {
                res.append(index)
            }
        }
        
        return res
    }

}
