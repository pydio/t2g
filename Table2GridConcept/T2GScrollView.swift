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
    var refreshControl: UIControl?
    
    func visibleCellCount(mode: T2GLayoutMode) -> Int {
        let dimensions = self.viewDelegate!.cellDimensions(self.viewDelegate!.currentLayout())
        
        if mode == .Table {
            let count = Int(ceil(self.frame.size.height / (dimensions.height + dimensions.padding)))
            println("Fitting in table: \(count)")
            return 10
        } else {
            let count = Int(ceil(self.frame.size.height / (dimensions.height + dimensions.padding))) * self.itemCountPerLine(.Collection)
            println("Fitting in collection: \(count)")
            return 20
        }
    }
    
    func itemCountPerLine(mode: T2GLayoutMode) -> Int {
        if mode == .Collection {
            let dimensions = self.viewDelegate!.cellDimensions(.Collection)
            return Int(floor(self.frame.size.width / dimensions.width))
        } else {
            return 1
        }
    }
    
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
            let count = self.itemCountPerLine(.Collection)
            let gap = (self.frame.size.width - (CGFloat(count) * dimensions.width)) / CGFloat(count + 1)
            
            var xCoords: [CGFloat] = []
            for index in 0..<count {
                let x = CGFloat(index) * (gap + dimensions.width) + gap
                xCoords.append(x)
            }
            
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
    
    func performSubviewCleanup() {
        for view in self.subviews {
            if let cell = view as? T2GCell {
                if !CGRectIntersectsRect(self.bounds, cell.frame) || cell.alpha == 0 {
                    cell.removeFromSuperview()
                }
            }
        }
    }
    
    //TODO: Functional approach or for cycle?
    func firstAndLastTags() -> (lowest: Int, highest: Int) {
        /*
        let startValues = (lowest: Int.max, highest: Int.min)
        var minMax:(lowest: Int, highest: Int) = subviews.reduce(startValues) { prev, next in
        (next as? T2GCell).map {
        (min(prev.lowest, $0.tag), max(prev.highest, $0.tag))
        } ?? prev
        }
        */
        
        var lowest = Int.max
        var highest = Int.min
        
        for view in self.subviews {
            if let cell = view as? T2GCell {
                lowest = lowest > cell.tag ? cell.tag : lowest
                highest = highest < cell.tag ? cell.tag : highest
            }
        }
        
        return (lowest, highest)
    }
    
    func contentSizeForMode(mode: T2GLayoutMode) -> CGSize {
        let dimensions = self.viewDelegate!.cellDimensions(mode)
        let viewX = mode == .Collection ? dimensions.padding : (self.superview!.frame.size.width - dimensions.width) / 2
        let divisor = self.itemCountPerLine(mode)
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
            var firstIndex = Int(floor((frame.origin.y - dimensions.height) / (dimensions.height + dimensions.padding))) * self.itemCountPerLine(.Collection)
            if firstIndex < 0 {
                firstIndex = 0
            }
            
            var lastIndex = firstIndex + 2 * self.visibleCellCount(.Collection)
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
            
            var lastIndex = firstIndex + self.visibleCellCount(.Table)
            if self.viewDelegate!.cellCount(0) - 1 < lastIndex {
                lastIndex = self.viewDelegate!.cellCount(0) - 1
            }
            
            for index in firstIndex...lastIndex {
                res.append(index)
            }
        }
        
        return res
    }
    
    func scrollContinously(speedCoefficient: CGFloat, stationaryFrame: CGRect, overlappingView: UIView?, navigationController: UINavigationController?) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            var toMove = self.contentOffset.y + (32.0 * speedCoefficient)
            
            if speedCoefficient < 0 {
                var minContentOffset: CGFloat = 0.0
                if let navigationBar = navigationController?.navigationBar {
                    minContentOffset -= (navigationBar.frame.origin.y + navigationBar.frame.size.height)
                }
                
                if toMove < minContentOffset {
                    toMove = minContentOffset
                }
            } else {
                let maxContentOffset = self.contentSize.height - self.frame.size.height
                if toMove > maxContentOffset {
                    toMove = maxContentOffset
                }
            }
            
            self.contentOffset = CGPointMake(self.contentOffset.x, toMove)
            }, completion: { (_) -> Void in
                if let overlappingCellView = overlappingView {
                    
                    var shouldContinueScrolling = true
                    if speedCoefficient < 0 {
                        var minContentOffset: CGFloat = 0.0
                        if let navigationBar = navigationController?.navigationBar {
                            minContentOffset -= (navigationBar.frame.origin.y + navigationBar.frame.size.height)
                        }
                        
                        if self.contentOffset.y == minContentOffset {
                            shouldContinueScrolling = false
                        }
                    } else {
                        let maxContentOffset = self.contentSize.height - self.frame.size.height
                        if self.contentOffset.y == self.contentSize.height - self.frame.size.height {
                            shouldContinueScrolling = false
                        }
                    }
                    
                    let newOverlappingViewFrame = overlappingCellView.frame
                    
                    if shouldContinueScrolling && CGRectIntersectsRect(stationaryFrame, newOverlappingViewFrame) {
                        let speedCoefficient2 = self.coefficientForOverlappingFrames(stationaryFrame, overlapping: newOverlappingViewFrame) * (speedCoefficient < 0 ? -1 : 1)
                        self.scrollContinously(speedCoefficient2, stationaryFrame: stationaryFrame, overlappingView: overlappingView, navigationController: navigationController)
                    } else {
                        self.addSubview(overlappingCellView)
                    }
                }
        })
    }
    
    func coefficientForOverlappingFrames(stationary: CGRect, overlapping: CGRect) -> CGFloat {
        let stationarySize = stationary.size.width * stationary.size.height
        let intersection = CGRectIntersection(stationary, overlapping)
        let intersectionSize = intersection.size.height * intersection.size.width
        return intersectionSize / stationarySize
    }

}
