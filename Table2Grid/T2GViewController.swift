//
//  T2GViewController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 25/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

protocol T2GViewControllerDelegate {
    /// View methods
    
    func cellForIndexPath(indexPath: NSIndexPath, frame: CGRect) -> T2GCell
    func titleForHeaderInSection(section: Int) -> String?
    func updateCellForIndexPath(cell: T2GCell, indexPath: NSIndexPath)
    
    /// Action methods
    
    func didSelectCellAtIndexPath(indexPath: NSIndexPath)
    func didSelectDrawerButtonAtIndex(indexPath: NSIndexPath, buttonIndex: Int)
    func willRemoveCellAtIndexPath(indexPath: NSIndexPath)
    // unused now
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    func willDeselectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    func didDeselectCellAtIndexPath(indexPath: NSIndexPath)
}

protocol T2GDropDelegate {
    func didDropCell(cell: T2GCell, onCell: T2GCell, completion: () -> Void, failure: () -> Void)
}

private enum T2GScrollingSpeed {
    case Slow
    case Normal
    case Fast
}

enum T2GViewTags: Int {
    case cellConstant = 333
    case editingModeToolbar = 777777
    case checkboxButton = 666666
    case cellDrawerButtonConstant = 555555
    case cellBackgroundButton = 444444
    case statusBarBackgroundView = 333333
    case refreshControl = 222222
}

class T2GViewController: T2GScrollController, T2GCellDelegate, T2GDragAndDropDelegate {
    var scrollView: T2GScrollView!
    var openCellTag: Int = -1
    
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
    
    var delegate: T2GViewControllerDelegate! {
        didSet {
            var count = self.scrollView.visibleCellCount(self.scrollView.layoutMode)
            let totalCells = self.scrollView.totalCellCount()
            count = count > totalCells ? totalCells : count
            
            for index in 0..<count {
                self.insertRowWithTag(index + T2GViewTags.cellConstant.rawValue)
            }
            self.scrollView.adjustContentSize()
        }
    }

    var dropDelegate: T2GDropDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationCtr = self.navigationController {
            if let naviCtr = navigationCtr as? T2GNaviViewController {
                naviCtr.segueDelay = 0.16
            }
        }
        
        self.scrollView = T2GScrollView()
        self.scrollView.backgroundColor = UIColor(red: 238.0/255.0, green: 233.0/255.0, blue: 233/255.0, alpha: 1.0)
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
        self.displayMissingCells(self.scrollView.layoutMode)
        self.scrollView.adjustContentSize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadScrollView() {
        for view in self.scrollView.subviews {
            if let cell = view as? T2GCell {
                self.delegate.updateCellForIndexPath(cell, indexPath: self.scrollView.indexPathForCell(cell.tag))
            }
        }
        
        self.displayMissingCells(self.scrollView.layoutMode)
    }
    
    //MARK: - Editing mode
    
    func toggleEdit() {
        if self.openCellTag != -1 {
            if let view = self.scrollView!.viewWithTag(self.openCellTag) as? T2GCell {
                view.closeCell()
            }
        }
        
        self.toggleEditingMode(!self.isEditingModeActive)
        self.toggleToolbar()
    }
    
    //TODO: Move multiple items
    func moveBarButtonPressed() {
        println("Not implemented yet.")
    }
    
    func deleteBarButtonPressed() {
        var indexPaths: [NSIndexPath] = []
        
        for key in self.editingModeSelection.keys {
            if self.editingModeSelection[key] == true {
                indexPaths.append(self.scrollView.indexPathForCell(key + T2GViewTags.cellConstant.rawValue))
            }
        }
        
        self.removeRowsAtIndexPaths(indexPaths.sorted{$0.section == $1.section ? $0.row < $1.row : $0.section < $1.section}, notifyDelegate: true)
        self.editingModeSelection = [Int : Bool]()
    }
    
    func toggleToolbar() {
        if let bar = self.view.viewWithTag(T2GViewTags.editingModeToolbar.rawValue) {
            bar.removeFromSuperview()
            self.scrollView.adjustContentSize()
        } else {
            let bar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
            bar.tag = T2GViewTags.editingModeToolbar.rawValue
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
    
    func toggleEditingMode(flag: Bool) {
        self.isEditingModeActive = flag
        
        for view in self.scrollView.subviews {
            if let cell = view as? T2GCell {
                let isSelected = self.editingModeSelection[cell.tag - T2GViewTags.cellConstant.rawValue] ?? false
                cell.toggleMultipleChoice(flag, mode: self.scrollView.layoutMode, selected: isSelected, animated: true)
            }
        }
    }
    
    //MARK: - CRUD methods
    
    func insertDelimiterForSection(mode: T2GLayoutMode, section: Int) {
        if self.scrollView.viewWithTag(section + 1) as? T2GDelimiterView == nil {
            let name = self.delegate.titleForHeaderInSection(section)
            
            let delimiter = T2GDelimiterView(frame: self.scrollView.frameForDelimiter(mode, section: section), title: name!)
            delimiter.tag = section + 1
            
            self.scrollView.addSubview(delimiter)
        }
    }
    
    func insertRowAtIndexPath(indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            for cell in self.scrollView.subviews {
                if cell.tag >= (indexPath.row + T2GViewTags.cellConstant.rawValue) {
                    if let c = cell as? T2GCell {
                        let newFrame = self.scrollView.frameForCell(self.scrollView.layoutMode, indexPath: self.scrollView.indexPathForCell(c.tag + 1))
                        c.frame = newFrame
                        c.tag = c.tag + 1
                        self.delegate.updateCellForIndexPath(c, indexPath: self.scrollView.indexPathForCell(c.tag))
                    }
                } else if let delimiter = cell as? T2GDelimiterView {
                    let frame = self.scrollView.frameForDelimiter(self.scrollView.layoutMode, section: delimiter.tag - 1)
                    delimiter.frame = frame
                }
            }
        }, completion: { (_) -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.scrollView.adjustContentSize()
            }, completion: { (_) -> Void in
                self.insertRowWithTag(indexPath.row + T2GViewTags.cellConstant.rawValue, animated: true)
                return
            })
        })
    }
    
    private func insertRowWithTag(tag: Int, animated: Bool = false) -> Int {
        let indexPath = self.scrollView.indexPathForCell(tag)
        
        if indexPath.row == 0 {
            self.insertDelimiterForSection(self.scrollView.layoutMode, section: indexPath.section)
        }
        
        if let cell = self.scrollView.viewWithTag(tag) {
            return cell.tag
        } else {
            let frame = self.scrollView.frameForCell(self.scrollView.layoutMode, indexPath: indexPath)
            let cellView = self.delegate.cellForIndexPath(indexPath, frame: frame)
            cellView.tag = tag
            
            if self.isEditingModeActive {
                let isSelected = self.editingModeSelection[cellView.tag - T2GViewTags.cellConstant.rawValue] ?? false
                cellView.toggleMultipleChoice(true, mode: self.scrollView.layoutMode, selected: isSelected, animated: false)
            }
            
            let isDragged = self.view.viewWithTag(tag) != nil
            
            cellView.delegate = self
            cellView.alpha = (animated || isDragged) ? 0 : 1
            self.scrollView.addSubview(cellView)
            
            if animated && !isDragged {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cellView.alpha = 1.0
                })
            }
            
            return cellView.tag
        }
    }
    
    func removeRowsAtIndexPaths(indexPaths: [NSIndexPath], notifyDelegate: Bool = false) {
        var indices: [Int] = []
        for indexPath in indexPaths {
            indices.append(self.scrollView.indexForIndexPath(indexPath))
        }
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            var removedCount = 0
            
            for idx in indices {
                if let view = self.scrollView!.viewWithTag(idx + T2GViewTags.cellConstant.rawValue) as? T2GCell {
                    if notifyDelegate {
                        self.delegate.willRemoveCellAtIndexPath(self.scrollView.indexPathForCell(idx - removedCount + T2GViewTags.cellConstant.rawValue))
                    }
                    
                    if self.openCellTag == view.tag {
                        view.closeCell()
                    }
                    
                    view.frame = CGRectMake(view.frame.origin.x - 40, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
                }
                removedCount += 1
            }
        }, completion: { (_) -> Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                for idx in indices {
                    if let view = self.scrollView!.viewWithTag(idx + T2GViewTags.cellConstant.rawValue) as? T2GCell {
                        view.frame = CGRectMake(self.scrollView.bounds.width + 40, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
                    }
                }   
            }, completion: { (_) -> Void in
                for idx in indices {
                    if let view = self.scrollView!.viewWithTag(idx + T2GViewTags.cellConstant.rawValue) as? T2GCell {
                        view.removeFromSuperview()
                    }
                }
                
                var tags = self.scrollView.subviews.filter({$0 is T2GCell || $0 is T2GDelimiterView}).map({(subview) -> Int in return subview.tag})
                tags.sort(<)
                        
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    var changedCount = 0
                    for tag in tags {
                        let firstIP = indexPaths.first!
                        let idx = self.scrollView.indexForIndexPath(firstIP)
                        
                        if let cell = self.scrollView.viewWithTag(tag) {
                            if cell.tag > (idx + T2GViewTags.cellConstant.rawValue) {
                                if let c = cell as? T2GCell {
                                    let newRowNum = idx + changedCount
                                    let newFrame = self.scrollView.frameForCell(self.scrollView.layoutMode, indexPath: self.scrollView.indexPathForCell(newRowNum + T2GViewTags.cellConstant.rawValue))
                                    c.frame = newFrame
                                    c.tag = newRowNum + T2GViewTags.cellConstant.rawValue
                                    self.delegate.updateCellForIndexPath(c, indexPath: self.scrollView.indexPathForCell(c.tag))
                                    
                                    changedCount += 1
                                }
                            } else if let delimiter = cell as? T2GDelimiterView {
                                let frame = self.scrollView.frameForDelimiter(self.scrollView.layoutMode, section: delimiter.tag - 1)
                                delimiter.frame = frame
                            }
                        }
                    }
                }, completion: { (_) -> Void in
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.scrollView.adjustContentSize()
                    }, completion: { (_) -> Void in
                        self.displayMissingCells(self.scrollView.layoutMode)
                    })
                })
            })
        })
    }
    
    //MARK: - View transformation (Table <-> Collection)
    
    func transformView() {
        self.transformViewWithCompletion() {()->Void in}
    }
    
    //TODO: Rearranging items when deep in view
    private func transformViewWithCompletion(completionClosure:() -> Void) {
        let collectionClosure = {() -> T2GLayoutMode in
            let indicesExtremes = self.scrollView.firstAndLastVisibleTags()
            var from = (indicesExtremes.highest) + 1
            
            if from > self.scrollView.totalCellCount() {
                from = self.scrollView.totalCellCount() - 1 + T2GViewTags.cellConstant.rawValue
            }
            
            var to = (indicesExtremes.highest) + 10
            if to > self.scrollView.totalCellCount() {
                to = self.scrollView.totalCellCount() - 1 + T2GViewTags.cellConstant.rawValue
            }
            
            
            for index in from...to {
                self.insertRowWithTag(index)
            }
            
            return .Collection
        }
        
        let mode = self.scrollView.layoutMode == .Collection ? T2GLayoutMode.Table : collectionClosure()
        self.scrollView.adjustContentSize(mode: mode)
        self.displayMissingCells(self.scrollView.layoutMode)
        self.displayMissingCells(mode)
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            
            for view in self.scrollView.subviews {
                if let cell = view as? T2GCell {
                    let frame = self.scrollView.frameForCell(mode, indexPath: self.scrollView.indexPathForCell(cell.tag))
                    
                    /*
                    * Not really working - TBD
                    *
                    if !didAdjustScrollview {
                    self.scrollView.scrollRectToVisible(CGRectMake(0, frame.origin.y - 12 - 64, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height), animated: false)
                    didAdjustScrollview = true
                    }
                    */
                    
                    cell.changeFrameParadigm(mode, frame: frame)
                } else if let delimiter = view as? T2GDelimiterView {
                    let frame = self.scrollView.frameForDelimiter(mode, section: delimiter.tag - 1)
                    delimiter.frame = frame
                }
            }
            
            }) { (_) -> Void in
                //self.scrollView.contentSize = self.contentSizeForCurrentMode()
                self.scrollView.performSubviewCleanup()
                completionClosure()
        }
        
        self.scrollView.layoutMode = mode
    }
    
    //MARK: - Rotation handler
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        
        let indicesExtremes = self.scrollView.firstAndLastVisibleTags()
        let from = (indicesExtremes.highest) + 1
        var to = (indicesExtremes.highest) + 10
        if (to - T2GViewTags.cellConstant.rawValue) < self.scrollView.totalCellCount() {
            for index in from...to {
                self.insertRowWithTag(index)
            }
        }
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            if let bar = self.view.viewWithTag(T2GViewTags.editingModeToolbar.rawValue) as? UIToolbar {
                let height: CGFloat = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 35.0 : 44.0
                bar.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)
            }
            
            for view in self.scrollView.subviews {
                if let cell = view as? T2GCell {
                    let frame = self.scrollView.frameForCell(self.scrollView.layoutMode, indexPath: self.scrollView.indexPathForCell(cell.tag))
                    cell.changeFrameParadigm(self.scrollView.layoutMode, frame: frame)
                } else if let delimiter = view as? T2GDelimiterView {
                    let frame = self.scrollView.frameForDelimiter(self.scrollView.layoutMode, section: delimiter.tag - 1)
                    delimiter.frame = frame
                }
            }
            
        }) { (_) -> Void in
            self.scrollView.adjustContentSize()
            self.scrollView.performSubviewCleanup()
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.displayMissingCells(self.scrollView.layoutMode)
    }
    
    //MARK: - ScrollView delegate
    
    override func handleSnapBack() {
        self.displayMissingCells(self.scrollView.layoutMode)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollView.performSubviewCleanup()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        if !decelerate {
            self.scrollView.performSubviewCleanup()
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
        
        let extremes = self.scrollView.firstAndLastVisibleTags()
        let startingPoint = self.scrollDirection == .Up ? extremes.lowest : extremes.highest
        let endingPoint = self.scrollDirection == .Up ? extremes.highest : extremes.lowest
        let edgeCondition = self.scrollDirection == .Up ? T2GViewTags.cellConstant.rawValue : self.scrollView.totalCellCount() + T2GViewTags.cellConstant.rawValue - 1
        
        let startingPointIndexPath = self.scrollView.indexPathForCell(extremes.lowest)
        let endingPointIndexPath = self.scrollView.indexPathForCell(extremes.highest)
        
        self.insertDelimiterForSection(self.scrollView.layoutMode, section: startingPointIndexPath.section)
        self.insertDelimiterForSection(self.scrollView.layoutMode, section: endingPointIndexPath.section)
        
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
                        if (currentSpeed == .Fast || self.scrollView.layoutMode == .Collection) && thirdAddedTag != edgeCondition {
                            let fourthAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: secondAddedTag)
                        }
                    }
                }
            }
        } else {
            self.displayMissingCells(self.scrollView.layoutMode)
        }
    }
    
    func displayMissingCells(mode: T2GLayoutMode) {
        let indices = self.scrollView.indicesForVisibleCells(mode)
        for index in indices {
            self.insertRowWithTag(index + T2GViewTags.cellConstant.rawValue, animated: true)
        }
    }
    
    func addRowsWhileScrolling(direction: T2GScrollDirection, startTag: Int) -> Int {
        var multiplier = direction == .Up ? -1 : 1
        var firstTag = startTag + (1 * multiplier)
        var secondTag = startTag + (2 * multiplier)
        var thirdTag = startTag + (3 * multiplier)
        
        let firstAdditionalCondition = direction == .Up ? secondTag - T2GViewTags.cellConstant.rawValue > 0 : secondTag - T2GViewTags.cellConstant.rawValue < (self.scrollView.totalCellCount() - 1)
        let secondAdditionalCondition = direction == .Up ? thirdTag - T2GViewTags.cellConstant.rawValue > 0 : thirdTag - T2GViewTags.cellConstant.rawValue < (self.scrollView.totalCellCount() - 1)
        
        var lastTag = self.insertRowWithTag(firstTag)
        
        if self.scrollView.layoutMode == .Collection {
            if firstAdditionalCondition {
                lastTag = self.insertRowWithTag(secondTag)
                
                if secondAdditionalCondition {
                    lastTag = self.insertRowWithTag(thirdTag)
                }
            }
        }
        
        return lastTag
    }
    
    //MARK: - T2GCell delegate
    
    func cellStartedSwiping(tag: Int) {
        if self.openCellTag != -1 && self.openCellTag != tag {
            let cell = self.view.viewWithTag(self.openCellTag) as? T2GCell
            cell?.closeCell()
        }
    }
    
    func didSelectCell(tag: Int) {
        self.delegate.didSelectCellAtIndexPath(self.scrollView.indexPathForCell(tag))
    }
    
    func didCellOpen(tag: Int) {
        self.openCellTag = tag
    }
    
    func didCellClose(tag: Int) {
        self.openCellTag = -1
    }
    
    func didSelectButton(tag: Int, index: Int) {
        self.delegate.didSelectDrawerButtonAtIndex(self.scrollView.indexPathForCell(tag), buttonIndex: index)
    }
    
    func didSelectMultipleChoiceButton(tag: Int, selected: Bool) {
        self.editingModeSelection[tag - T2GViewTags.cellConstant.rawValue] = selected
    }
    
    //MARK: - T2GCellDragAndDrop delegate
    
    func findBiggestOverlappingView(excludedTag: Int, frame: CGRect) -> UIView? {
        var winningView:UIView?
        
        var winningRect:CGRect = CGRectMake(0, 0, 0, 0)
        
        for view in self.scrollView.subviews {
            if let c = view as? T2GCell {
                if c.tag != excludedTag {
                    if CGRectIntersectsRect(frame, c.frame) {
                        if winningView == nil {
                            winningView = c
                            winningRect = winningView!.frame
                        } else {
                            if (c.frame.size.height * c.frame.size.width) > (winningRect.size.height * winningRect.size.width) {
                                winningView!.alpha = 1.0
                                winningView = c
                                winningRect = winningView!.frame
                            } else {
                                c.alpha = 1.0
                            }
                        }
                    } else {
                        c.alpha = 1.0
                    }
                }
            }
        }
        
        return winningView
    }
    
    func didMove(tag: Int, frame: CGRect) {
        let height: CGFloat = 30.0
        
        var frameInView = self.scrollView.convertRect(frame, toView: self.view)
        
        var topOrigin = self.scrollView.convertPoint(CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y), toView: self.view)
        if let navigationBar = self.navigationController {
            topOrigin.y += navigationBar.navigationBar.frame.origin.y + navigationBar.navigationBar.frame.size.height
        }
        let topStrip = CGRectMake(0, topOrigin.y, self.scrollView.frame.size.width, height)
        
        if CGRectIntersectsRect(topStrip, frameInView) {
            let subview = self.view.viewWithTag(tag)
            let isFirstEncounter = subview?.superview is UIScrollView
            self.view.addSubview(subview!)
            
            if isFirstEncounter {
                let speedCoefficient = self.scrollView.coefficientForOverlappingFrames(topStrip, overlapping: frameInView) * -1
                self.scrollView.scrollContinously(speedCoefficient, stationaryFrame: topStrip, overlappingView: subview, navigationController: self.navigationController)
            }
        }
        
        let bottomOrigin = self.scrollView.convertPoint(CGPointMake(0, self.scrollView.contentOffset.y + self.scrollView.frame.size.height - height), toView: self.view)
        let bottomStrip = CGRectMake(0, bottomOrigin.y, self.scrollView.frame.size.width, height)
        
        if CGRectIntersectsRect(bottomStrip, frameInView) {
            let subview = self.view.viewWithTag(tag)
            let isFirstEncounter = subview?.superview is UIScrollView
            self.view.addSubview(subview!)
            
            if isFirstEncounter {
                let speedCoefficient = self.scrollView.coefficientForOverlappingFrames(bottomStrip, overlapping: frameInView)
                self.scrollView.scrollContinously(speedCoefficient, stationaryFrame: bottomStrip, overlappingView: subview, navigationController: self.navigationController)
            }
        }
        
        let winningView = self.findBiggestOverlappingView(tag, frame: frame)
        winningView?.alpha = 0.3
    }
    
    func didDrop(view: T2GDragAndDropView) {
        self.scrollView.performSubviewCleanup()
        
        if let win = self.findBiggestOverlappingView(view.tag, frame: view.frame) as? T2GCell {
            win.alpha = 1.0
            
            self.dropDelegate?.didDropCell(view as T2GCell, onCell: win, completion: { () -> Void in
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    let transform = CGAffineTransformMakeScale(1.07, 1.07)
                    win.transform = transform
                    
                    view.center = win.center
                    
                    let transform2 = CGAffineTransformMakeScale(0.1, 0.1)
                    view.transform = transform2
                }, completion: { (_) -> Void in
                    view.removeFromSuperview()
                        
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        let transform = CGAffineTransformMakeScale(1.0, 1.0)
                        win.transform = transform
                    }, completion: { (_) -> Void in
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            for v in self.scrollView.subviews {
                                if let c = v as? T2GCell {
                                    if c.tag > view.tag {
                                        let newFrame = self.scrollView.frameForCell(self.scrollView.layoutMode, indexPath: self.scrollView.indexPathForCell(c.tag - 1))
                                        c.frame = newFrame
                                        c.tag = c.tag - 1
                                        self.delegate.updateCellForIndexPath(c, indexPath: self.scrollView.indexPathForCell(c.tag))
                                    }
                                } else if let delimiter = v as? T2GDelimiterView {
                                    let frame = self.scrollView.frameForDelimiter(self.scrollView.layoutMode, section: delimiter.tag - 1)
                                    delimiter.frame = frame
                                }
                            }
                        }, completion: { (_) -> Void in
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.scrollView.adjustContentSize()
                            }, completion: { (_) -> Void in
                                self.displayMissingCells(self.scrollView.layoutMode)
                            })
                        })
                    })
                })
            }, failure: { () -> Void in
                UIView.animateWithDuration(0.3) {
                    view.frame = CGRectMake(view.origin.x, view.origin.y, view.frame.size.width, view.frame.size.height)
                }
            })
            
        } else {
            UIView.animateWithDuration(0.3) {
                view.frame = CGRectMake(view.origin.x, view.origin.y, view.frame.size.width, view.frame.size.height)
            }
        }
    }
}
