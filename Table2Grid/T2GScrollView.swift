//
//  T2GScrollView.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 14/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

protocol T2GScrollViewDataDelegate {
    func currentLayout() -> T2GLayoutMode
    func delimiterDimensions() -> CGSize
    func cellDimensions(mode: T2GLayoutMode) -> (width: CGFloat, height: CGFloat, padding: CGFloat)
    func cellCount(inSection: Int) -> Int
    func sectionCount() -> Int
}

class T2GScrollView: UIScrollView {
    var dataDelegate: T2GScrollViewDataDelegate?
    var refreshControl: UIControl? {
        didSet {
            self.addSubview(self.refreshControl!)
        }
    }
    
    func visibleCellCount(mode: T2GLayoutMode) -> Int {
        let dimensions = self.dataDelegate!.cellDimensions(self.dataDelegate!.currentLayout())
        var count = 0
        
        if mode == .Table {
            count = Int(ceil(self.frame.size.height / (dimensions.height + dimensions.padding)))
            if count == 0 {
                if let superframe = self.superview?.frame {
                    count = Int(ceil(superframe.size.height / (dimensions.height + dimensions.padding)))
                }
                
                count = count == 0 ? 10 : count
            }
        } else {
            count = Int(ceil(self.frame.size.height / (dimensions.height + dimensions.padding))) * self.itemCountPerLine(.Collection)
            count = count == 0 ? 20 : count
        }
        
        return count
    }
    
    func itemCountPerLine(mode: T2GLayoutMode) -> Int {
        if mode == .Collection {
            let dimensions = self.dataDelegate!.cellDimensions(.Collection)
            return Int(floor(self.frame.size.width / dimensions.width))
        } else {
            return 1
        }
    }
    
    func frameForCell(mode: T2GLayoutMode, indexPath: NSIndexPath) -> CGRect {
        let superviewFrame = self.superview!.frame
        let dimensions = self.dataDelegate!.cellDimensions(mode)
        
        if mode == .Collection {
            /// Assuming that the collection is square of course
            let count = self.itemCountPerLine(.Collection)
            let gap = (self.frame.size.width - (CGFloat(count) * dimensions.width)) / CGFloat(count + 1)
            
            var xCoords: [CGFloat] = []
            for index in 0..<count {
                let x = CGFloat(index) * (gap + dimensions.width) + gap
                xCoords.append(x)
            }
            
            var yCoord = dimensions.padding + (CGFloat(indexPath.row / xCoords.count) * (dimensions.height + dimensions.padding)) + self.dataDelegate!.delimiterDimensions().height
            for section in 0..<indexPath.section {
                yCoord += (self.dataDelegate!.delimiterDimensions().height + (CGFloat(ceil(CGFloat(self.dataDelegate!.cellCount(section)) / CGFloat(xCoords.count))) * (dimensions.height + dimensions.padding)))
            }
            
            let frame = CGRectMake(CGFloat(xCoords[indexPath.row % xCoords.count]), yCoord, dimensions.width, dimensions.height)
            
            return frame
            
        } else {
            let viewX = (superviewFrame.size.width - dimensions.width) / 2
            
            var ypsilon = viewX + (CGFloat(indexPath.row) * (dimensions.height + dimensions.padding)) + self.dataDelegate!.delimiterDimensions().height
            
            for section in 0..<indexPath.section {
                ypsilon += (self.dataDelegate!.delimiterDimensions().height + (CGFloat(self.dataDelegate!.cellCount(section)) * (dimensions.height + dimensions.padding)))
            }
            
            return CGRectMake(viewX, ypsilon, dimensions.width, dimensions.height)
        }
    }
    
    func alignVisibleCells() {
        for view in self.subviews {
            if let cell = view as? T2GCell {
                let frame = self.frameForCell(self.dataDelegate!.currentLayout(), indexPath: self.indexPathForCell(cell.tag))
                if cell.frame.origin.x != frame.origin.x || cell.frame.origin.y != frame.origin.y || cell.frame.size.width != frame.size.width || cell.frame.size.height != frame.size.height {
                    cell.changeFrameParadigm(self.dataDelegate!.currentLayout(), frame: frame)
                }
            }
        }
    }
    
    //MARK: - Animation methods
    
    func animateSubviewCells(isGoingOffscreen: Bool) {
        var delayCount: Double = 0.0
        let xOffset: CGFloat = isGoingOffscreen ? -150 : 150
        
        var tags = self.subviews.map({($0 as UIView).tag})
        tags.sort(isGoingOffscreen ? {$0 > $1} : {$0 < $1})
        
        for tag in tags {
            if let view = self.viewWithTag(tag) as? T2GCell {
                let frame = self.frameForCell(self.dataDelegate!.currentLayout(), indexPath: self.indexPathForCell(view.tag))
                
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
    
    func performSubviewCleanup() {
        for view in self.subviews {
            if let cell = view as? T2GCell {
                if !CGRectIntersectsRect(self.bounds, cell.frame) || cell.alpha == 0 {
                    cell.removeFromSuperview()
                }
            }
        }
    }
    
    
    //MARK: - Helper methods
    
    func indexForIndexPath(indexPath: NSIndexPath) -> Int {
        var totalIndex = indexPath.row
        for section in 0..<indexPath.section {
            totalIndex += self.dataDelegate!.cellCount(section)
        }
        
        return totalIndex
    }
    
    func indexPathForCell(tag: Int) -> NSIndexPath {
        let index = tag - T2GViewTags.cellConstant.rawValue
        
        var row = 0
        var section = 0
        
        var currentMax = 0
        for sectionIndex in 0..<self.dataDelegate!.sectionCount() {
            let cellsInSection = self.dataDelegate!.cellCount(sectionIndex)
            currentMax += cellsInSection
            if currentMax > index {
                row = index - (currentMax - cellsInSection)
                section = sectionIndex
                break
            }
        }
        
        return NSIndexPath(forRow: row, inSection: section)
    }
    
    func totalCellCount() -> Int {
        var total = 0
        for section in 0..<self.dataDelegate!.sectionCount() {
            total += self.dataDelegate!.cellCount(section)
        }
        
        return total
    }

    func contentSizeForMode(mode: T2GLayoutMode) -> CGSize {
        let dimensions = self.dataDelegate!.cellDimensions(mode)
        let viewX = mode == .Collection ? dimensions.padding : (self.superview!.frame.size.width - dimensions.width) / 2
        let divisor = self.itemCountPerLine(mode)
        
        var lineCount = 0
        for section in 0..<self.dataDelegate!.sectionCount() {
            lineCount += (Int(ceil(Double((self.dataDelegate!.cellCount(section) - 1) / divisor))) + 1)
        }
        lineCount -= 1

        let ypsilon = viewX + (CGFloat(lineCount) * (dimensions.height + dimensions.padding))
        var height = ypsilon + dimensions.height + dimensions.padding + (CGFloat(self.dataDelegate!.sectionCount()) * self.dataDelegate!.delimiterDimensions().height)
        height = height < self.bounds.height ? (self.bounds.height - 31.0) : height
        
        return CGSize(width: self.superview!.frame.size.width, height: height)
    }
    
    //TODO: Functional approach or for cycle?
    func firstAndLastVisibleTags() -> (lowest: Int, highest: Int) {
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
    
    func indicesForVisibleCells(mode: T2GLayoutMode) -> [Int] {
        let frame = self.bounds
        var res = [Int]()
        let dimensions = self.dataDelegate!.cellDimensions(mode)
        
        if mode == .Collection {
            var firstIndex = Int(floor(((frame.origin.y - dimensions.height) - (CGFloat(self.dataDelegate!.sectionCount()) * self.dataDelegate!.delimiterDimensions().height)) / (dimensions.height + dimensions.padding))) * self.itemCountPerLine(.Collection)
            if firstIndex < 0 {
                firstIndex = 0
            }
            
            var lastIndex = firstIndex + 2 * self.visibleCellCount(.Collection)
            if self.totalCellCount() - 1 < lastIndex {
                lastIndex = self.totalCellCount() - 1
            }
            
            for index in firstIndex...lastIndex {
                res.append(index)
            }
        } else {
            var firstIndex = Int(floor(((frame.origin.y - dimensions.height) - (CGFloat(self.dataDelegate!.sectionCount()) * self.dataDelegate!.delimiterDimensions().height)) / (dimensions.height + dimensions.padding)))
            if firstIndex < 0 {
                firstIndex = 0
            }
            
            var lastIndex = firstIndex + self.visibleCellCount(.Table)
            if self.totalCellCount() - 1 < lastIndex {
                lastIndex = self.totalCellCount() - 1
            }
            
            if lastIndex != -1 {
                for index in firstIndex...lastIndex {
                    res.append(index)
                }
            }
        }
        
        return res
    }
    
    //MARK: Continuous scroll
    
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
