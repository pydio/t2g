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
    func updateCellForIndexPath(cell: T2GCell, indexPath: NSIndexPath)
    
    /// View methods
    
    //func dimensionsForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    func didSelectCellAtIndexPath(indexPath: NSIndexPath)
    func willDeselectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    func didDeselectCellAtIndexPath(indexPath: NSIndexPath)
    func didSelectDrawerButtonAtIndex(indexPath: NSIndexPath, buttonIndex: Int)
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
    
    var isEditingModeActive: Bool = false {
        didSet {
            if !self.isEditingModeActive {
                self.editingModeSelection = [Int : Bool]()
            }
        }
    }
    var editingModeSelection = [Int : Bool]()
    
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
        //self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor(red: 238.0/255.0, green: 233.0/255.0, blue: 233/255.0, alpha: 1.0) //UIColor.lightGrayColor()
        self.view.addSubview(scrollView)
        
        // View must be added to hierarchy before setting constraints.
        self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = ["view": self.view, "scroll_view": scrollView]
        
        var constH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scroll_view]|", options: .AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(constH)
        
        var constW = NSLayoutConstraint.constraintsWithVisualFormat("V:|[scroll_view]|", options: .AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(constW)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.scrollView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func toggleEdit() {
        if self.openCellTag != -1 {
            if let view = self.scrollView!.viewWithTag(self.openCellTag) as? T2GCell {
                view.closeCell()
            }
        }
        
        self.toggleMultipleChoiceMode(!self.isEditingModeActive)
        self.toggleToolbar()
    }
    
    func moveBarButtonPressed() {
        println("move")
    }
    
    func deleteBarButtonPressed() {
        for key in self.editingModeSelection.keys {
            if self.editingModeSelection[key] == true {
                self.removeRowAtIndexPath(NSIndexPath(forRow: key, inSection: 0))
            }
        }
    }
    
    func toggleToolbar() {
        if let bar = self.view.viewWithTag(777777) {
            bar.removeFromSuperview()
            self.scrollView.contentSize = self.contentSizeForMode(self.layoutMode)
        } else {
            let bar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
            bar.tag = 777777
            bar.translucent = false
            
            let leftItem = UIBarButtonItem(title: "Move", style: UIBarButtonItemStyle.Plain, target: self, action: "moveBarButtonPressed")
            let rightItem = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.Plain, target: self, action: "deleteBarButtonPressed")
            let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            bar.items = [leftItem, space, rightItem]
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 44.0)
            bar.alpha = 0.0
            self.view.addSubview(bar)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                bar.alpha = 1.0
            })
        }
    }
    
    func toggleMultipleChoiceMode(flag: Bool) {
        let completionClosure = { () -> Void in
            self.isEditingModeActive = flag
            
            for view in self.scrollView.subviews {
                if let cell = view as? T2GCell {
                    let isSelected = self.editingModeSelection[cell.tag - 333] ?? false
                    cell.toggleMultipleChoice(flag, selected: isSelected, animated: true)
                }
            }
        }
        
        if self.layoutMode == .Collection {
            self.transformViewWithCompletion(completionClosure)
        } else {
            completionClosure()
        }
    }
    
    func insertRowAtIndexPath(indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            for cell in self.scrollView.subviews {
                if cell.tag >= (indexPath.row + 333) {
                    if let c = cell as? T2GCell {
                        let newFrame = self.frameForCell(self.layoutMode, yOffset: 12, index: c.tag - 333 + 1)
                        c.frame = newFrame
                        c.tag = c.tag + 1
                        self.delegate.updateCellForIndexPath(c, indexPath: NSIndexPath(forRow: c.tag - 333, inSection: 0))
                    }
                }
            }
        }, completion: { (complete3) -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.scrollView.contentSize = self.contentSizeForMode(self.layoutMode)
            }, completion: { (complete) -> Void in
                self.insertRowWithTag(indexPath.row + 333, animated: true)
                return
            })
        })
    }
    
    private func insertRowWithTag(tag: Int, animated: Bool = false) -> Int {
        if let cell = self.scrollView.viewWithTag(tag) {
            return cell.tag
        } else {
            let cellView = self.delegate.cellForIndexPath(NSIndexPath(forRow: tag - 333, inSection: 0))
            cellView.tag = tag
            
            if self.isEditingModeActive {
                let isSelected = self.editingModeSelection[cellView.tag - 333] ?? false
                cellView.toggleMultipleChoice(true, selected: isSelected, animated: false)
            }
            
            cellView.delegate = self
            cellView.alpha = animated ? 0 : 1
            self.scrollView.addSubview(cellView)
            if animated {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cellView.alpha = 1.0
                })
            }
            
            return cellView.tag
        }
    }
    
    func contentSizeForCurrentMode() -> CGSize {
        let viewWidth = self.view.frame.size.width * 0.9
        let viewX = (self.view.frame.size.width - viewWidth) / 2
        let viewHeight = self.layoutMode == .Collection ? 100 : 64
        let divisor = self.layoutMode == .Collection ? 3 : 1
        let lineCount = Int(ceil(Double((self.delegate.numberOfCellsInSection(0) - 1) / divisor)))
        let ypsilon = CGFloat(viewX) + CGFloat(lineCount * (viewHeight + 12))
        let height = ypsilon + CGFloat(viewHeight) + CGFloat(12.0)
        
        return CGSize(width: self.view.frame.size.width, height: height)
    }
    
    func contentSizeForMode(mode: T2GLayoutMode) -> CGSize {
        let viewWidth = self.view.frame.size.width * 0.9
        let viewX = (self.view.frame.size.width - viewWidth) / 2
        let viewHeight = mode == .Collection ? 100 : 64
        let divisor = mode == .Collection ? 3 : 1
        let lineCount = Int(ceil(Double((self.delegate.numberOfCellsInSection(0) - 1) / divisor)))
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
        self.transformViewWithCompletion() {()->Void in}
    }
    
    func transformViewWithCompletion(completionClosure:() -> Void) {
        let collectionClosure = {() -> T2GLayoutMode in
            let indicesExtremes = self.firstAndLastTags(self.scrollView.subviews)
            var from = (indicesExtremes.highest) + 1
            if from > self.delegate.numberOfCellsInSection(0) {
                from = self.delegate.numberOfCellsInSection(0) - 1 + 333
            }
            
            var to = (indicesExtremes.highest) + 10
            if to > self.delegate.numberOfCellsInSection(0) {
                to = self.delegate.numberOfCellsInSection(0) - 1 + 333
            }
            
            
            for index in from...to {
                self.insertRowWithTag(index)
            }
            
            return .Collection
        }
        
        let mode = self.layoutMode == .Collection ? T2GLayoutMode.Table : collectionClosure()
        self.scrollView.contentSize = self.contentSizeForMode(mode)
        self.displayMissingCells(self.layoutMode)
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
                //self.scrollView.contentSize = self.contentSizeForCurrentMode()
                self.performSubviewCleanup()
                completionClosure()
        }
        
        self.layoutMode = mode
    }
    
    func removeRowAtIndexPath(indexPath: NSIndexPath) {
        if let view = self.scrollView!.viewWithTag(indexPath.row + 333) as? T2GCell {
            view.closeCell()
            
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                view.frame = CGRectMake(view.frame.origin.x - 40, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
            }, completion: { (complete) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    view.frame = CGRectMake(self.scrollView.bounds.width + 40, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
                }, completion: { (complete2) -> Void in
                    view.removeFromSuperview()
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        for cell in self.scrollView.subviews {
                            if cell.tag > view.tag {
                                if let c = cell as? T2GCell {
                                    let newFrame = self.frameForCell(self.layoutMode, yOffset: 12, index: c.tag - 333 - 1)
                                    c.frame = newFrame
                                    c.tag = c.tag - 1
                                    self.delegate.updateCellForIndexPath(c, indexPath: NSIndexPath(forRow: c.tag - 333, inSection: 0))
                                }
                            }
                        }
                    }, completion: { (complete3) -> Void in
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.scrollView.contentSize = self.contentSizeForMode(self.layoutMode)
                        }, completion: { (complete) -> Void in
                            self.displayMissingCells(self.layoutMode)
                        })
                    })
                })
            })
        }
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
        let edgeCondition = self.scrollDirection == .Up ? 333 : self.delegate.numberOfCellsInSection(0) + 333 - 1
        
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
            self.insertRowWithTag(index + 333, animated: true)
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
    
    func didSelectButton(tag: Int, index: Int) {
        self.delegate.didSelectDrawerButtonAtIndex(NSIndexPath(forRow: tag, inSection: 0), buttonIndex: index)
    }
    
    func didSelectMultipleChoiceButton(tag: Int, selected: Bool) {
        self.editingModeSelection[tag - 333] = selected
    }

}
