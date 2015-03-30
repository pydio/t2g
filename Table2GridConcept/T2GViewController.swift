//
//  T2GViewController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 25/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

protocol T2GViewControllerDelegate {
    /// Datasource methods
    
    func cellForIndexPath(indexPath: NSIndexPath) -> T2GCell
    func numberOfSectionsInT2GView() -> Int
    func numberOfCellsInSection(section: Int) -> Int
    func titleForHeaderInSection(section: Int) -> String?
    
    /// View methods
    
    //func dimensionsForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    func didSelectCellAtIndexPath(indexPath: NSIndexPath)
    func willDeselectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    func didDeselectCellAtIndexPath(indexPath: NSIndexPath)
}

enum T2GLayoutMode {
    case Table
    case Collection
    
    init(){
        self = .Table
    }
}

private enum T2GScrollingSpeed {
    case Slow
    case Normal
    case Fast
}

class T2GViewController: T2GScrollController, T2GCellDelegate {
    var scrollView: UIScrollView!
    var layoutMode: T2GLayoutMode = T2GLayoutMode()
    var openCellTag: Int = -1
    
    let rowHeight = 64
    let yOffset = 12
    let squareSize = 100
    
    var lastSpeedOffset: CGPoint = CGPointMake(0, 0)
    var lastSpeedOffsetCaptureTime: NSTimeInterval = 0
    
    private var visibleCellCount: Int {
        get {
            if self.layoutMode == .Table {
                return 10
            } else {
                return 20
            }
        }
    }
    
    var delegate: T2GViewControllerDelegate! {
        didSet {
            for index in 0..<self.visibleCellCount {
                self.insertRowWithTag(index + 333)
            }
            self.scrollView.contentSize = self.contentSizeForCurrentMode()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationCtr = self.navigationController {
            self.statusBarBackgroundView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 20))
            self.statusBarBackgroundView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07)
            navigationCtr.view.addSubview(self.statusBarBackgroundView!)
            
            navigationCtr.navigationBar.barTintColor = self.statusBarBackgroundViewColor
            navigationCtr.navigationBar.tintColor = .whiteColor()
        }
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(scrollView)
        
        // View must be added to hierarchy before setting constraints.
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = ["view": self.view, "scroll_view": scrollView]
        
        var constH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scroll_view]|", options: .AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(constH)
        
        var constW = NSLayoutConstraint.constraintsWithVisualFormat("V:|[scroll_view]|", options: .AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(constW)
        
        var rightButton_add: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "transformView")
        self.navigationItem.rightBarButtonItem = rightButton_add
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func insertRowWithTag(tag: Int) -> Int {
        if let cell = self.scrollView.viewWithTag(tag) {
            return cell.tag
        } else {
            let cellView = self.delegate.cellForIndexPath(NSIndexPath(forRow: tag - 333, inSection: 0))
            cellView.tag = tag
            cellView.delegate = self
            self.scrollView.addSubview(cellView)
            return cellView.tag
        }
    }
    
    func contentSizeForCurrentMode() -> CGSize {
        let viewWidth = self.view.frame.size.width * 0.9
        let viewX = (self.view.frame.size.width - viewWidth) / 2
        let viewHeight = self.layoutMode == .Collection ? 100 : 64
        let divisor = self.layoutMode == .Collection ? 3 : 1
        let lineCount = Int(ceil(Double(self.delegate.numberOfCellsInSection(0) / divisor)))
        let ypsilon = CGFloat(viewX) + CGFloat(lineCount * (viewHeight + 12))
        let height = ypsilon + CGFloat(viewHeight) + CGFloat(12.0)
        
        return CGSize(width: self.view.frame.size.width, height: height)
    }
    
    func frameForCell(mode: T2GLayoutMode, yOffset: Int = 0, index: Int = 0) -> CGRect {
        let frame = self.view.frame
        
        if mode == .Collection {
            let squareSize = 100
            
            let middle = (frame.size.width - CGFloat(squareSize))/2
            let left = (middle - CGFloat(squareSize))/2
            let right = middle + CGFloat(squareSize) + left
            var xCoords = [left, middle, right]
            
            let yCoord = CGFloat(yOffset) + CGFloat(index / xCoords.count * (squareSize + 12))
            let frame = CGRectMake(CGFloat(xCoords[index % xCoords.count]), yCoord, CGFloat(squareSize), CGFloat(squareSize))
            
            return frame
            
        } else {
            let viewWidth = frame.size.width * 0.9
            let viewX = (frame.size.width - viewWidth) / 2
            let viewHeight = 64
            let ypsilon = CGFloat(viewX) + CGFloat(index * (viewHeight + yOffset))
            
            return CGRectMake(viewX, ypsilon, viewWidth, CGFloat(viewHeight))
        }
    }
    
    func indicesForVisibleCells(mode: T2GLayoutMode, yOffset: Int = 0) -> [Int] {
        let frame = self.scrollView.bounds
        var res = [Int]()
        
        if mode == .Collection {
            var firstIndex = Int(floor((frame.origin.y - 100.0) / (100.0 + 12.0))) * 3
            if firstIndex < 0 {
                firstIndex = 0
            }
            
            var lastIndex = firstIndex + 2 * self.visibleCellCount
            if self.delegate.numberOfCellsInSection(0) - 1 < lastIndex {
                lastIndex = self.delegate.numberOfCellsInSection(0) - 1
            }
            
            for index in firstIndex...lastIndex {
                res.append(index)
            }
        } else {
            var firstIndex = Int(floor((frame.origin.y - 64.0) / (64.0 + 12.0)))
            if firstIndex < 0 {
                firstIndex = 0
            }
            
            var lastIndex = firstIndex + self.visibleCellCount
            if self.delegate.numberOfCellsInSection(0) - 1 < lastIndex {
                lastIndex = self.delegate.numberOfCellsInSection(0) - 1
            }
            
            for index in firstIndex...lastIndex {
                res.append(index)
            }
        }
        
        return res
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        
        let indicesExtremes = self.firstAndLastTags(self.scrollView.subviews)
        let from = (indicesExtremes.highest) + 1
        let to = (indicesExtremes.highest) + 10
        
        for index in from...to {
            self.insertRowWithTag(index)
        }
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            for view in self.scrollView.subviews {
                if let cell = view as? T2GCell {
                    let frame = self.frameForCell(self.layoutMode, yOffset: 12, index: cell.tag - 333)
                    cell.changeFrameParadigm(self.layoutMode, frame: frame)
                }
            }
            
        }) { (Bool) -> Void in
            self.scrollView.contentSize = self.contentSizeForCurrentMode()
            self.performSubviewCleanup()
        }
    }
    
    func transformView() {
        let collectionClosure = {() -> T2GLayoutMode in
            let indicesExtremes = self.firstAndLastTags(self.scrollView.subviews)
            let from = (indicesExtremes.highest) + 1
            let to = (indicesExtremes.highest) + 10
            
            for index in from...to {
                self.insertRowWithTag(index)
            }

            return .Collection
        }
        
        let mode = self.layoutMode == .Collection ? T2GLayoutMode.Table : collectionClosure()
        
        self.displayMissingCells(mode)
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            for view in self.scrollView.subviews {
                if let cell = view as? T2GCell {
                    let frame = self.frameForCell(mode, yOffset: 12, index: cell.tag - 333)
                    
                    /*
                     * Not really working - TBD
                     *
                    if !didAdjustScrollview {
                        self.scrollView.scrollRectToVisible(CGRectMake(0, frame.origin.y - 12 - 64, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height), animated: false)
                        didAdjustScrollview = true
                    }
                    */
                    
                    cell.changeFrameParadigm(mode, frame: frame)
                }
            }
            
        }) { (Bool) -> Void in
            self.scrollView.contentSize = self.contentSizeForCurrentMode()
            self.performSubviewCleanup()
        }
        
        self.layoutMode = mode
    }
    
    //MARK: - ScrollView delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.performSubviewCleanup()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        if !decelerate {
            self.performSubviewCleanup()
        }
    }
    
    func performSubviewCleanup() {
        for view in self.scrollView.subviews {
            if let cell = view as? T2GCell {
                if !CGRectIntersectsRect(scrollView.bounds, cell.frame) {
                    cell.removeFromSuperview()
                }
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        var currentOffset = scrollView.contentOffset;
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var currentSpeed = T2GScrollingSpeed.Slow
        
        if(currentTime - self.lastSpeedOffsetCaptureTime > 0.1) {
            var distance = currentOffset.y - self.lastSpeedOffset.y
            var scrollSpeed = fabsf(Float((distance * 10) / 1000))
            
            if (scrollSpeed > 6) {
                currentSpeed = .Fast
            } else if scrollSpeed > 0.5 {
                currentSpeed = .Normal
            }
            
            self.lastSpeedOffset = currentOffset
            self.lastSpeedOffsetCaptureTime = currentTime
        }
        
        let extremes = self.firstAndLastTags(scrollView.subviews)
        let startingPoint = self.scrollDirection == .Up ? extremes.lowest : extremes.highest
        let endingPoint = self.scrollDirection == .Up ? extremes.highest : extremes.lowest
        let edgeCondition = self.scrollDirection == .Up ? 333 : self.delegate.numberOfCellsInSection(0) + 333
        
        if let cell = scrollView.viewWithTag(endingPoint) as? T2GCell {
            if !CGRectIntersectsRect(scrollView.bounds, cell.frame) {
                cell.removeFromSuperview()
            }
        }
        
        if let edgeCell = scrollView.viewWithTag(startingPoint) as? T2GCell {
            if CGRectIntersectsRect(scrollView.bounds, edgeCell.frame) && startingPoint != edgeCondition {
                let firstAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: startingPoint)
                if (currentSpeed == .Fast || currentSpeed == .Normal) && firstAddedTag != edgeCondition {
                    let secondAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: firstAddedTag)
                    if (currentSpeed == .Fast) && secondAddedTag != edgeCondition {
                        let thirdAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: secondAddedTag)
                        if (currentSpeed == .Fast || self.layoutMode == .Collection) && thirdAddedTag != edgeCondition {
                            let fourthAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: secondAddedTag)
                        }
                    }
                }
            }
        } else {
            self.displayMissingCells(self.layoutMode)
        }
    }
    
    func displayMissingCells(mode: T2GLayoutMode) {
        let indices = self.indicesForVisibleCells(mode, yOffset: 12)
        for index in indices[0]...indices[indices.count - 1] {
            self.insertRowWithTag(index + 333)
        }
    }
    
    func addRowsWhileScrolling(direction: T2GScrollDirection, startTag: Int) -> Int {
        var multiplier = direction == .Up ? -1 : 1
        var firstTag = startTag + (1 * multiplier)
        var secondTag = startTag + (2 * multiplier)
        var thirdTag = startTag + (3 * multiplier)
        
        let firstAdditionalCondition = direction == .Up ? secondTag - 333 > 0 : secondTag - 333 < (self.delegate.numberOfCellsInSection(0) - 1)
        let secondAdditionalCondition = direction == .Up ? thirdTag - 333 > 0 : thirdTag - 333 < (self.delegate.numberOfCellsInSection(0) - 1)
        
        var lastTag = self.insertRowWithTag(firstTag)
        
        if self.layoutMode == .Collection {
            if firstAdditionalCondition {
                lastTag = self.insertRowWithTag(secondTag)
                
                if secondAdditionalCondition {
                    lastTag = self.insertRowWithTag(thirdTag)
                }
            }
        }
        
        return lastTag
    }
    
    func firstAndLastTags(subviews: [AnyObject]) -> (lowest: Int, highest: Int) {
        ///
        //let startDate: NSDate = NSDate()
        ///
        
        //let startValues = (lowest: Int.max, highest: Int.min)
        
        /*
        var extremes:(lowest: Int, highest: Int) = subviews.filter({$0 is T2GCell}).reduce(startValues) {
            (min($0.lowest, $1.tag), max($0.highest, $1.tag))
        }
        */

        //var extremes2 = reduce(lazy(subviews).filter({$0 is T2GCell}), startValues) {
        //    (min($0.lowest, $1.tag), max($0.highest, $1.tag))
        //}
        
        /*
        var minMax = reduce(subviews, startValues) {
            $1 is T2GCell ? (min($0.lowest, $1.tag), max($0.highest, $1.tag)) : $0
        }
        */
        
        //var minMax:(lowest: Int, highest: Int) = subviews.reduce(startValues) { prev, next in (next as? T2GCell).map { (min(prev.lowest, $0.tag), max(prev.highest, $0.tag)) } ?? prev }
        
        ///
        //let subDate: NSDate = NSDate()
        ///
        
        var lowest = Int.max
        var highest = Int.min
        
        for view in subviews {
            if let cell = view as? T2GCell {
                lowest = lowest > cell.tag ? cell.tag : lowest
                highest = highest < cell.tag ? cell.tag : highest
            }
        }
        
        ///
        //let endDate: NSDate = NSDate()
        ///
        
//        let time1 = subDate.timeIntervalSinceDate(startDate) * 1000
//        let time2 = endDate.timeIntervalSinceDate(subDate) * 1000
//        let timeString = String(format: "1: %.5f | 2: %.5f", time1, time2)
//        println(timeString)
//        println("MINF: \(minMax.lowest), MAXF: \(minMax.highest) | MIN: \(lowest), MAX: \(highest)")
        //println("\(lowest) to \(highest)")
        
        return (lowest, highest)
    }
    
    //MARK: - T2GCell delegate
    
    func cellStartedSwiping(tag: Int) {
        if self.openCellTag != -1 && self.openCellTag != tag {
            let cell = self.view.viewWithTag(self.openCellTag) as? T2GCell
            cell?.closeCell()
        }
    }
    
    func didCellOpen(tag: Int) {
        self.openCellTag = tag
    }
    
    func didCellClose(tag: Int) {
        self.openCellTag = -1
    }

}
