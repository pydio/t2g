//
//  T2GScrollView.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 14/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Enum defining the state of the T2GScrollView. Table by default if not stated otherwise.
*/
public enum T2GLayoutMode {
    case table
    case collection
    
    init() {
        self = .table
    }
}

/**
Protocol for scrollView delegate defining all key dimensional methods to be able to render all the cells precisely.
*/
public protocol T2GScrollViewDataDelegate: class {
    /**
    Returns the number of sections in the datasource.
    
    :returns: Integer value defining number of sections.
    */
    func numberOfSections() -> Int
    
    /**
    Returns the number of cells in given section.
    
    :param: section Integer value representing the section, indexed from 0.
    :returns: Integer value defining number of cells in given section.
    */
    func numberOfCellsInSection(_ section: Int) -> Int
    
    /**
    Returns the dimensions for the cell in given layout mode.
    
    :param: mode T2GLayoutMode for which dimensions should be calculated.
    :returns: Tuple of width, height and padding for the cell.
    */
    func dimensionsForCell(_ mode: T2GLayoutMode) -> (width: CGFloat, height: CGFloat, padding: CGFloat)
    
    /**
    Returns the dimensions for the section header.
    
    - DISCUSSION: Will be most likely renamed to heightForSectionHeader, because the width is left out and is stretched to the full width.
    
    :returns: CGSize object defining width and height.
    */
    func dimensionsForSectionHeader() -> CGSize
}

/**
Custom UIScrollView class that takes care of all the T2GCell objects and displays them.
*/
open class T2GScrollView: UIScrollView {
    deinit {
        print("\(#file)\(#function)")
    }
    
    weak open var dataDelegate: T2GScrollViewDataDelegate?
//    open var refreshControl: UIControl? {
//        didSet {
//            self.addSubview(self.refreshControl!)
//        }
//    }
    open var layoutMode: T2GLayoutMode = T2GLayoutMode()
    
    /**
    Helps not to delay the touchUpInside event on a UIButton that could possibly be a subview.
    
    - DISCUSSION: referenced from: http://stackoverflow.com/questions/3642547/uibutton-touch-is-delayed-when-in-uiscrollview

    override func touchesShouldCancelInContentView(view: UIView!) -> Bool {
        if view is T2GCell {
            return true
        }
        
        return  super.touchesShouldCancelInContentView(view)
    }
    */
    
    /**
    Returns the number of cells per line in given mode.
    
    :param: mode T2GLayoutMode for which the line cell count should be calculated.
    :returns: Integer value representing the number of cells for given mode.
    */
    func itemCountPerLine(_ mode: T2GLayoutMode) -> Int {
        if mode == .collection {
            let dimensions = dataDelegate!.dimensionsForCell(.collection)
            return Int(floor(frame.size.width / dimensions.width))
        } else {
            return 1
        }
    }
    
    /**
    Returns the number of cells that SHOULD be visible at the moment for the given mode.
    
    :param: mode T2GLayoutMode for which the count should be calculated. Optional value - if nothing is passed, current layout is used.
    :returns:
    */
    func visibleCellCount(_ mode: T2GLayoutMode? = nil) -> Int {
        let m = mode ?? layoutMode
        
        let dimensions = dataDelegate!.dimensionsForCell(layoutMode)
        var count = 0
        
        if m == .table {
            count = Int(ceil(frame.size.height / (dimensions.height + dimensions.padding)))
            if count == 0 {
                    count = Int(ceil(frame.size.height / (dimensions.height + dimensions.padding)))
                
                count = count == 0 ? 10 : count
            }
        } else {
            count = Int(ceil(frame.size.height / (dimensions.height + dimensions.padding))) * itemCountPerLine(.collection)
            count = count == 0 ? 20 : count
        }
        
        return count
    }
    
    /**
    Returns the exact frame for cell at given indexPath.
    
    :param: mode T2GLayoutMode for which the cell frame should be calculated. Optional value - if nothing is passed, current layout is used.
    :param: indexPath NSIndexPath object for the given cell.
    :returns: CGRect object with origin and size parameters filled and ready to be used on the T2GCell view.
    */
    func frameForCell(_ mode: T2GLayoutMode? = nil, indexPath: IndexPath) -> CGRect {
        let m = mode ?? layoutMode
        
        let dimensions = dataDelegate!.dimensionsForCell(m)
        
        if m == .collection {
            /// Assuming that the collection is square of course
            let count = itemCountPerLine(.collection)
            
            
            
            let gap: CGFloat = 3.00
            
            var xCoords: [CGFloat] = []
            for index in 0..<count {
                let x = CGFloat(index) * (gap + dimensions.width) + gap
                xCoords.append(x)
            }
            
            var yCoord = dimensions.padding + (CGFloat(indexPath.row / xCoords.count) * (dimensions.height + dimensions.padding)) + dataDelegate!.dimensionsForSectionHeader().height
            for section in 0..<indexPath.section {
                yCoord += (dataDelegate!.dimensionsForSectionHeader().height + (CGFloat(ceil(CGFloat(dataDelegate!.numberOfCellsInSection(section)) / CGFloat(xCoords.count))) * (dimensions.height + dimensions.padding)))
            }
            
            let frame = CGRect(x: CGFloat(xCoords[indexPath.row % xCoords.count]), y: yCoord, width: dimensions.width, height: dimensions.height)
            
            return frame
            
        } else {
            let superviewFrame = frame
            var ypsilon = (CGFloat(indexPath.row) * (dimensions.height + dimensions.padding)) + dataDelegate!.dimensionsForSectionHeader().height
            
            for section in 0..<indexPath.section {
                ypsilon += (dataDelegate!.dimensionsForSectionHeader().height + (CGFloat(dataDelegate!.numberOfCellsInSection(section)) * (dimensions.height + dimensions.padding)))
            }
            
            return CGRect(x: 0, y: ypsilon, width: dimensions.width, height: dimensions.height)
        }
    }
    
    /**
    Returns the exact frame for delimiter for given section.
    
    :param: mode T2GLayoutMode for which the delimiter frame should be calculated. Optional value - if nothing is passed, current layout is used.
    :param: section Integer value representing the section.
    :returns: CGRect object with origin and size parameters filled and ready to be used on the T2GDelimiter view.
    */
    func frameForDelimiter(_ mode: T2GLayoutMode? = nil, section: Int) -> CGRect {
        let m = mode ?? layoutMode
        
        let x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        let dimensions = dataDelegate!.dimensionsForSectionHeader()
        let height: CGFloat = dimensions.height
        let width: CGFloat = frame.size.width
        
        let cellDimensions = dataDelegate!.dimensionsForCell(m)
        
        if section != 0 {
            let count = itemCountPerLine(m)
            
            if m == .collection {
                y = cellDimensions.padding
            } else {
                y = (superview!.frame.size.width - cellDimensions.width) / 2
            }
            
            for idx in 0..<section {
                let lineCount = CGFloat(ceil(CGFloat(dataDelegate!.numberOfCellsInSection(idx)) / CGFloat(count)))
                y += (height + (lineCount * (cellDimensions.height + cellDimensions.padding)))
            }
            
            y -= (CGFloat(cellDimensions.padding / 2.0))
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    /**
    Adjusts the content size of the scrollView depending on the number of cells.
    If the content height size if lower than then the scrollview height size, the content height size is set to scrollView height size + 1 to allow the scrollView to scroll for the refresh control.
    :param: mode T2GLayoutMode for which the content size should be calculated. Optional value - if nothing is passed, current layout is used.
    */
    func adjustContentSize(_ mode: T2GLayoutMode? = nil) {
        if let m = mode {
            contentSize = contentSizeForMode(m)
        } else {
            contentSize = contentSizeForMode(layoutMode)
        }
        if contentSize.height <= frame.height {
            contentSize = CGSize(width: frame.width, height: frame.height + 1)
        }
    }
    
    /**
    Aligns all the visible cells to make them be where they are (useful after rotation).
    */
    open func alignVisibleCells() {
        for view in subviews {
            if let cell = view as? T2GCell {
                let frame = frameForCell(indexPath: indexPathForCell(cell.tag))
                if cell.frame.origin.x != frame.origin.x || cell.frame.origin.y != frame.origin.y || cell.frame.size.width != frame.size.width || cell.frame.size.height != frame.size.height {
                    cell.changeFrameParadigm(layoutMode, frame: frame)
                }
            } else {
                if let delimiter = view as? T2GDelimiterView {
                    let frame = frameForDelimiter(section: delimiter.tag - 1)
                    delimiter.frame = frame
                }
            }
        }
    }
    
    //MARK: - Animation methods
    
    /**
    Animates cells when the view controller owning the scrollView is going on/off screen.
    
    :params: isGoingOffscreen Boolean value defining whether the view is going offscreen or not.
    */
    func animateSubviewCells(_ isGoingOffscreen: Bool) {
        var delayCount: Double = 0.0
        let xOffset: CGFloat = isGoingOffscreen ? -150 : 150
        
        var tags = subviews.map({($0).tag})
        tags.sort(by: isGoingOffscreen ? {$0 < $1} : {$0 < $1})
        
        for tag in tags {
            if let view = viewWithTag(tag) as? T2GCell {
                let frame = frameForCell(indexPath: indexPathForCell(view.tag))
                
                if isGoingOffscreen || view.frame.origin.x != frame.origin.x {
                    delayCount += 1.0
                    let delay: Double = delayCount * 0.02
                    UIView.animate(withDuration: 0.2, delay: delay, options: [], animations: { () -> Void in
                        view.frame = CGRect(x: view.frame.origin.x + xOffset, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
                    }, completion: nil)
                }
            }
        }
    }
    
    /**
    Removes all the views that are not currently visible.
    */
    func performSubviewCleanup() {
        for view in subviews {
            if let cell = view as? T2GCell {
                if !bounds.intersects(cell.frame) || cell.alpha == 0 {
                    cell.removeFromSuperview()
                }
            } else if let delimiter = view as? T2GDelimiterView , !bounds.intersects(delimiter.frame) {
                delimiter.removeFromSuperview()
            }
        }
    }
    
    
    //MARK: - Helper methods
    
    /**
    Calculates the total index for given index path.
    
    :param: indexPath NSIndexPath object of the given cell.
    :returns: Integer value representing the total index.
    */
    func indexForIndexPath(_ indexPath: IndexPath) -> Int {
        var totalIndex = indexPath.row
        for section in 0..<indexPath.section {
            totalIndex += dataDelegate!.numberOfCellsInSection(section)
        }
        
        return totalIndex
    }
    
    /**
    Calculates the index path for given TAG of a cell.
    
    - DISCUSSION: Maybe it would be cleaner to already send an index instead of a TAG, but it is not anything that would be of a concern.
    
    :param: tag Integer value of the given cell.
    :returns: NSIndexPath object will full description (row and section) of the placement of the cell.
    */
    func indexPathForCell(_ tag: Int) -> IndexPath {
        let index = tag - T2GViewTags.cellConstant
        
        var row = 0
        var section = 0
        
        var currentMax = 0
        for sectionIndex in 0..<dataDelegate!.numberOfSections() {
            let cellsInSection = dataDelegate!.numberOfCellsInSection(sectionIndex)
            currentMax += cellsInSection
            if currentMax > index {
                row = index - (currentMax - cellsInSection)
                section = sectionIndex
                break
            }
        }
        
        return IndexPath(row: row, section: section)
    }
    
    /**
    Returns total count of all the cells in all the sections from the datasource.
    
    :returns: Integer value representing the number of cells.
    */
    func totalCellCount() -> Int {
        var total = 0
        for section in 0..<dataDelegate!.numberOfSections() {
            total += dataDelegate!.numberOfCellsInSection(section)
        }
        
        return total
    }

    /**
    Calculates the content size of the scrollView for the given mode based on current datasource status.
    
    :param: mode T2GLayoutMode for which the content size should be calculated.
    :returns: CGSize object to be set as the scrollView's contentSize.
    */
    func contentSizeForMode(_ mode: T2GLayoutMode) -> CGSize {
        var height: CGFloat = 0.0
        
        if let dimensions = dataDelegate?.dimensionsForCell(mode) {
            let viewX = mode == .collection ? dimensions.padding : (frame.size.width - dimensions.width) / 2
            let divisor = itemCountPerLine(mode)
            
            var lineCount = 0
            for section in 0..<dataDelegate!.numberOfSections() {
                lineCount += (Int(ceil(Double((dataDelegate!.numberOfCellsInSection(section) - 1) / divisor))) + 1)
            }
            lineCount -= 1
            
            let ypsilon = viewX + (CGFloat(lineCount) * (dimensions.height + dimensions.padding))
            height = ypsilon + dimensions.height + dimensions.padding + (CGFloat(dataDelegate!.numberOfSections()) * dataDelegate!.dimensionsForSectionHeader().height)
            height = height < bounds.height ? (bounds.height - 31.0) : height
        }
        return CGSize(width: frame.size.width, height: height + 90)
    }
    
    /**
    Returns the highest and lowest tags of the visible cells.
    
    - DISCUSSION: Functional approach or for cycle?
    
    :returns: Tuple with two integer values representing the TAGs.
    */
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
        
        for view in subviews {
            if let cell = view as? T2GCell {
                lowest = lowest > cell.tag ? cell.tag : lowest
                highest = highest < cell.tag ? cell.tag : highest
            }
        }
        
        return (lowest, highest)
    }
    
    /**
    Returns the indices of all the cells that SHOULD be visible for the given mode at the given contentOffset (self.bounds).
    
    :param: mode T2GLayoutMode for which the indices should be calculated.
    :returns: Array of integer values representing the total indices of the cells.
    */
    func indicesForVisibleCells(_ mode: T2GLayoutMode) -> [Int] {
        let frame = bounds
        var res = [Int]()
        
        if let dimensions = dataDelegate?.dimensionsForCell(mode) {
            if mode == .collection {
                let v = ((frame.origin.y - dimensions.height) - (CGFloat(dataDelegate!.numberOfSections()) * dataDelegate!.dimensionsForSectionHeader().height)) / (dimensions.height + dimensions.padding)
                var firstIndex = Int(floor(v)) * itemCountPerLine(.collection)
                if firstIndex < 0 {
                    firstIndex = 0
                }
                
                var lastIndex = firstIndex + 2 * visibleCellCount(.collection)
                if totalCellCount() - 1 < lastIndex {
                    lastIndex = totalCellCount() - 1
                }
                if lastIndex >= firstIndex {
                    for index in firstIndex...lastIndex {
                        res.append(index)
                    }                
                }
            } else {
                let v = ((frame.origin.y - dimensions.height) - (CGFloat(dataDelegate!.numberOfSections()) * dataDelegate!.dimensionsForSectionHeader().height)) / (dimensions.height + dimensions.padding)
                var firstIndex = Int(floor(v))
                if firstIndex < 0 {
                    firstIndex = 0
                }
                
                var lastIndex = firstIndex + visibleCellCount(.table)
                if totalCellCount() - 1 < lastIndex {
                    lastIndex = totalCellCount() - 1
                }
                
                if lastIndex >= firstIndex {
                    for index in firstIndex...lastIndex {
                        res.append(index)
                    }
                }
            }
        }
        
        return res
    }
    
    //MARK: Continuous scroll
    
    /**
    Gets called when dragged view gets dragged to the bottom/top of the scrollView. This method then decides how and where should it scroll.
    
    :param: speedCoefficient CGFloat value defining how fast should the continuous scroll be.
    :param: stationaryFrame CGRect object defining top/bottom of the scrollView towards which the overlap is calculated.
    :param: overlappingView UIView being measured with the stationaryFrame, most likely a T2GDragAndDropView object.
    :param: navigationController Optional object that makes sure the stationaryFrame gets pulled lower in case navigation bar is present.
    */
    func scrollContinously(_ speedCoefficient: CGFloat, stationaryFrame: CGRect, overlappingView: UIView?, navigationController: UINavigationController?) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
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
            
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: toMove)
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
//                    let maxContentOffset = self.contentSize.height - self.frame.size.height
                    if self.contentOffset.y == self.contentSize.height - self.frame.size.height {
                        shouldContinueScrolling = false
                    }
                }
                    
                let newOverlappingViewFrame = overlappingCellView.frame
                    
                if shouldContinueScrolling && stationaryFrame.intersects(newOverlappingViewFrame) {
                    let speedCoefficient2 = self.coefficientForOverlappingFrames(stationaryFrame, overlapping: newOverlappingViewFrame) * (speedCoefficient < 0 ? -1 : 1)
                    self.scrollContinously(speedCoefficient2, stationaryFrame: stationaryFrame, overlappingView: overlappingView, navigationController: navigationController)
                } else {
                    self.addSubview(overlappingCellView)
                }
            }
        })
    }
    
    /**
    Helper method calculating the speed of the continuous scroll. Calculates the ratio of overlapping of two frames.
    
    :param: stationary CGRect defining the stationary view.
    :param: overlapping CGRect defining the moving view.
    :returns: CGFloat with the value defining the speed.
    */
    func coefficientForOverlappingFrames(_ stationary: CGRect, overlapping: CGRect) -> CGFloat {
        let stationarySize = stationary.size.width * stationary.size.height
        let intersection = stationary.intersection(overlapping)
        let intersectionSize = intersection.size.height * intersection.size.width
        return intersectionSize / stationarySize
    }
}
