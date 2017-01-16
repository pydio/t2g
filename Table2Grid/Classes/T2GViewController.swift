//
//  T2GViewController.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 25/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit
import Material

/**
Protocol for view controller delegate defining required methods to properly display all subviews and also to define action methods to be called when an event occurrs.
*/
public protocol T2GViewControllerDelegate: class {
    /// View methods
    /**
     Enable/Disable Swipe back action see in NodeViewController for more details.
     
     :param: enabled: boolean that indicate if the user can swipe back on the previous view controller.
     */
    func backGestureStatus(_ enabled: Bool)
    
    /**
    Creates and returns a T2GCell object ready to be put in the scrollView.
    
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    :param: frame Expected frame for the cell.
    :returns:
    */
    func cellForIndexPath(_ indexPath: IndexPath, frame: CGRect) -> T2GCell
    
    /**
    Returns the header text for section delimiter.
    
    :param: section Integer value defining the targetted section.
    :returns: Optional String to be set in the UILabel of T2GDelimiterView
    */
    func titleForHeaderInSection(_ section: Int) -> String?
    
    /**
     Return a view to fill the section delimiter
    
     :param: section Integer value defining the targetted section.
     :returns: Optional UIView to be set in the section delimiter
     */
    func viewForHeaderInSection(_ section: Int) -> UIView?
    
    
    /**
    Gets called when cell needs an update.
    
    :param: cell T2GCell view to be updated.
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    */
    func updateCellForIndexPath(_ cell: T2GCell, indexPath: IndexPath)
    
    /// Action methods
    
    /**
    Gets called when cell is tapped.
    
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    */
    func didSelectCellAtIndexPath(_ indexPath: IndexPath)

    /**
     Gets called when cell is long pressed.
     
     :param: indexPath NSIndexPath object with precise location of the cell (row and section).
     */
    func didLongPressedCellAtIndexPath(_ indexPath: IndexPath)
    
    /**
     Gets called when cell is checked from multi-selection.
     
     :param: indexPath NSIndexPath object with precise location of the cell (row and section).
     */
    func didCheckCellAtIndexPath(_ indexPath: IndexPath)

    
    
    /**
     Gets called when cell is unchecked from multi-selection.
     
     :param: indexPath NSIndexPath object with precise location of the cell (row and section).
     */
    func didUncheckCellAtIndexPath(_ indexPath: IndexPath)
   
    
    
    /**
    Gets called when button in the drawer is tapped.
    
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    :param: buttonIndex Index of the button in the drawer - indexed from right to left starting with 0.
    */
    func didSelectDrawerButtonAtIndex(_ indexPath: IndexPath, buttonIndex: Int)
    
    /**
    Gets called when a cell will be removed from the scrollView.
    
    :param: NSIndexPath object with precise location of the cell (row and section).
    */
    func willRemoveCellAtIndexPath(_ indexPath: IndexPath)
    
    /**
    Unused at the moment. Planned for future development.
    */
    func willSelectCellAtIndexPath(_ indexPath: IndexPath) -> IndexPath?
    
    /**
    Unused at the moment. Planned for future development.
    */
    func willDeselectCellAtIndexPath(_ indexPath: IndexPath) -> IndexPath?
    
    /**
     Unused at the moment. Planned for future development.
     */
    func didDeselectCellAtIndexPath(_ indexPath: IndexPath)
}

/**
 Protocol for delegate handling drop event.
 */
protocol T2GDropDelegate: class {
    /**
     Gets called when a T2GCell gets dropped on top of another cell. This method should handle the event of success/failure.
     
     :param: cell Dragged cell.
     :param: onCell Cell on which the dragged cell has been dropped.
     :param: completion Completion closure to be performed in case the drop has been successful.
     :param: failure Failure closure to be performed in case the drop has not been successful.
     */
    func didDropCell(_ cell: T2GCell, onCell: T2GCell, completion: () -> Void, failure: () -> Void)
}

/**
 Enum defining scrolling speed. Used for deciding how fast should rows be added in method addRowsWhileScrolling.
 */
private enum T2GScrollingSpeed {
    case slow
    case normal
    case fast
}

/**
 Custom view controller class handling the whole T2G environment (meant to be overriden for customizations).
 */
open class T2GViewController: T2GScrollController {
    open var scrollView: T2GScrollView!
    var openCellTag: Int = -1
    
    var lastSpeedOffset: CGPoint = CGPoint(x: 0, y: 0)
    var lastSpeedOffsetCaptureTime: TimeInterval = 0
    
    open var isEditingModeActive: Bool = false {
        didSet {
            if !self.isEditingModeActive {
                self.editingModeSelection = [Int : Bool]()
            }
        }
    }
    var editingModeSelection = [Int : Bool]()
    
    deinit {
        print("DEINIT CALLED")
    }
    
    weak open var delegate: T2GViewControllerDelegate! {
        didSet {
            var count = self.scrollView.visibleCellCount()
            let totalCells = self.scrollView.totalCellCount()
            count = count > totalCells ? totalCells : count
            
            for index in 0..<count {
                self.insertRowWithTag(index + T2GViewTags.cellConstant)
            }
            self.scrollView.adjustContentSize()
        }
    }
    weak var dropDelegate: T2GDropDelegate?
    
    /**
    Sets slight delay for VC push in case T2GNaviViewController is present. Then adds scrollView to the view with constraints such that the scrollView is always the same size as the superview.
    */
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        prepareScrollView()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
    }
    
    fileprivate func prepareScrollView() {
        scrollView = T2GScrollView()
        scrollView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245/255.0, alpha: 1.0)
        scrollView.adjustContentSize()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let horizontalConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraintTop = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let verticalConstraintBottom = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraintTop)
        view.addConstraint(verticalConstraintBottom)
        let widthConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        view.addConstraint(widthConstraint)
        view.addConstraint(heightConstraint)
    }
    
    fileprivate func updateScrollView() {
        for view in scrollView.subviews {
            if let cell = view as? T2GCell {
                let frame = scrollView.frameForCell(indexPath: scrollView.indexPathForCell(cell.tag))
                cell.changeFrameParadigm(scrollView.layoutMode, frame: frame)
            } else if let delimiter = view as? T2GDelimiterView {
                let frame = scrollView.frameForDelimiter(section: delimiter.tag - 1)
                delimiter.frame = frame
            }
        }
    }
    
    /**
     Sets the scrollView delegate to be self. Makes sure that all cells that should be visible are visible.
     
     :param: animated Default Cocoa API - If YES, the view was added to the window using an animation.
     */
    override open func viewDidAppear(_ animated: Bool) {
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Reloads the whole scrollView - does NOT delete everything, rather calls update on every visible cell.
     */
    open func reloadScrollView() {
        for view in scrollView.subviews {
            if let cell = view as? T2GCell {
                delegate.updateCellForIndexPath(cell, indexPath: scrollView.indexPathForCell(cell.tag))
            }
        }
        displayMissingCells()
        scrollView.adjustContentSize()
    }
    
    open func refreshScrollView() {
        clearScrollView()
        displayMissingCells()
        scrollView.adjustContentSize()
    }
    /**
     Clear the scrollview by removing each subview inside
     */
    
    open func clearScrollView() {
        for view in scrollView.subviews {
            if let cell: UIView = view {
                if !(cell is UIRefreshControl) {
                    cell.removeFromSuperview()
                }
            }
        }
    }
    
    //MARK: - Editing mode
    
    /**
     Turns on editing mode - all cells are moved and displayed with checkbox button. Also a toolbar in the botom of the screen appears.
     
     - DISCUSSION: How to make this more modular and settable? Maybe another delegate method.
     */
    open func toggleEdit() {
        if openCellTag != -1 {
            if let view = scrollView!.viewWithTag(openCellTag) as? T2GCell {
                view.closeCell()
            }
        }
        
        isEditingModeActive = !isEditingModeActive
        
        for view in scrollView.subviews {
            if let cell = view as? T2GCell {
                let isSelected = editingModeSelection[cell.tag - T2GViewTags.cellConstant] ?? false
                cell.selected = nil
                cell.toggleMultipleChoice(isEditingModeActive, mode: scrollView.layoutMode, selected: isSelected, animated: true)
            }
        }
        if isEditingModeActive {
            toggleSelectionPanel()
        }
    }
    
    /**
     Closes the cell at the given indexPath. Does nothing if the cell isn't visible anymore.
     
     :param: indexPath NSIndexPath of the given cell.
     */
    open func closeCell(_ indexPath: IndexPath) {
        let index = scrollView.indexForIndexPath(indexPath)
        
        if let cell = scrollView.viewWithTag(index + T2GViewTags.cellConstant) as? T2GCell {
            cell.closeCell()
        }
    }
    
    
    /**
     Gets called when delete button in the toolbar has been pressed and therefore multiple rows should be deleted. Animates all the visible/potentinally visible after the animation, notifies the delegate before doing so to adjust the model so the new cell frames could be calculated.
     */
    func deleteBarButtonPressed() {
        var indexPaths: [IndexPath] = []
        
        for key in editingModeSelection.keys {
            if editingModeSelection[key] == true {
                indexPaths.append(scrollView.indexPathForCell(key + T2GViewTags.cellConstant))
            }
        }
        
        removeRowsAtIndexPaths(indexPaths.sorted(by: {($0 as NSIndexPath).section == ($1 as NSIndexPath).section ? ($0 as NSIndexPath).row < ($1 as NSIndexPath).row : ($0 as NSIndexPath).section < ($1 as NSIndexPath).section}), notifyDelegate: true)
        editingModeSelection = [Int : Bool]()
    }
    
    func toggleSelectionPanel() {
        delegate.didLongPressedCellAtIndexPath(IndexPath(row: 0, section: 0))
    }
    
    //MARK: - CRUD methods
    
    /**
    Inserts delimiter for the given section.
    
    :param: mode T2GLayoutMode for which the delimiter's frame should be calculated.
    :param: section Integer value representing the section of the delimiter to ask for the title accordingly.
    */
    func insertDelimiterForSection(_ mode: T2GLayoutMode, section: Int) {
        if scrollView.viewWithTag(section + 1) as? T2GDelimiterView == nil {
            let name = delegate.titleForHeaderInSection(section) ?? ""
            
            let delimiter = T2GDelimiterView(frame: scrollView.frameForDelimiter(mode, section: section), title: name)
            delimiter.tag = section + 1
            
            if let v = delegate.viewForHeaderInSection(section) {
                delimiter.addSubview(v)
                delimiter.addConstraints([
                    NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: delimiter, attribute: .top, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: v, attribute: .bottom, relatedBy: .equal, toItem: delimiter, attribute: .bottom, multiplier: 1, constant: -1),
                    NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: delimiter, attribute: .leading, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: delimiter, attribute: .trailing, multiplier: 1, constant: 0),
                    ])
            }
            scrollView.addSubview(delimiter)
        }
    }
    
    
    /**
     Inserts cells in given indexPaths.
     
     :param: indexPaths
     */
    open func insertRowsAtIndexPath(_ indexPaths: [IndexPath]) {
        for i in indexPaths {
            insertRowAtIndexPath(i)
        }
    }
    
    /**
    Inserts cell in given indexPath.
    
    :param: indexPath
    */
    fileprivate func insertRowAtIndexPath(_ indexPath: IndexPath) {
        let totalIndex = scrollView.indexForIndexPath(indexPath)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            for cell in self.scrollView.subviews {
                if cell.tag >= (totalIndex + T2GViewTags.cellConstant) {
                    if let c = cell as? T2GCell {
                        let newFrame = self.scrollView.frameForCell(indexPath: self.scrollView.indexPathForCell(c.tag + 1))
                        c.frame = newFrame
                        c.tag = c.tag + 1
                        self.delegate.updateCellForIndexPath(c, indexPath: self.scrollView.indexPathForCell(c.tag))
                    }
                } else if let delimiter = cell as? T2GDelimiterView {
                    let frame = self.scrollView.frameForDelimiter(section: delimiter.tag - 1)
                    delimiter.frame = frame
                }
            }
        }, completion: { (_) -> Void in
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.scrollView.adjustContentSize()
            }, completion: { (_) -> Void in
                self.insertRowWithTag(totalIndex + T2GViewTags.cellConstant, animated: true)
                return
            })
        })
    }
    
    /**
     Inserts cell with given tag. Meant mainly for internal use as it is strongly advised not to use the internal tags.
     
     :param: tag Integer value representing the tag of the new cell.
     :param: animated Boolean flag determining if the cell should be added animated.
     :returns: Integer value representing the tag of the newly added cell.
     */
    fileprivate func insertRowWithTag(_ tag: Int, animated: Bool = false) -> Int {
        let indexPath = scrollView.indexPathForCell(tag)
        
        if indexPath.row == 0 {
            insertDelimiterForSection(scrollView.layoutMode, section: indexPath.section)
        }
        
        if let cell = scrollView.viewWithTag(tag) {
            return cell.tag
        } else {
            let frame = scrollView.frameForCell(indexPath: indexPath)
            let cellView = delegate.cellForIndexPath(indexPath, frame: frame)
            cellView.tag = tag
            
            if isEditingModeActive {
                let isSelected = editingModeSelection[cellView.tag - T2GViewTags.cellConstant] ?? false
                cellView.toggleMultipleChoice(true, mode: scrollView.layoutMode, selected: isSelected, animated: false)
            }
            
            let isDragged = view.viewWithTag(tag) != nil
            
            cellView.delegate = self
            cellView.alpha = (animated || isDragged) ? 0 : 1
            scrollView.addSubview(cellView)
            
            if animated && !isDragged {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    cellView.alpha = 1.0
                })
            }
            
            return cellView.tag
        }
    }
    
    
    
    open func updateRowsAtIndexPaths(_ indexPaths: [IndexPath]) {
        for i in indexPaths {
            updateRowAtIndexPath(i)
        }
    }
    
    fileprivate func updateRowAtIndexPath(_ indexPath: IndexPath) {
        for view in scrollView.subviews {
            if let cell = view as? T2GCell {
                if scrollView.indexPathForCell(cell.tag) == indexPath {
                    delegate.updateCellForIndexPath(cell, indexPath: scrollView.indexPathForCell(cell.tag))
                }
            }
        }
        scrollView.adjustContentSize()
        displayMissingCells()
    }
    
    /**
    Removes rows at given indexPaths. Used even for single row removal.
    
    :param: indexPaths Array of NSIndexPath objects defining the positions of the cells.
    :param: notifyDelegate Boolean flag saying whether or not the delegate should be notified about the removal - maybe the call was performed before the model has been adjusted.
    */
    open func removeRowsAtIndexPaths(_ indexPaths: [IndexPath], notifyDelegate: Bool = false) {
        var indices: [Int] = []
        guard !indexPaths.isEmpty else {
            return
        }
        for indexPath in indexPaths {
            indices.append(scrollView.indexForIndexPath(indexPath))
        }
        
        
        for idx in indices {
            if let view = scrollView!.viewWithTag(idx + T2GViewTags.cellConstant) as? T2GCell {
                view.removeFromSuperview()
            }
        }
        reloadScrollView()
        scrollView.adjustContentSize()
        displayMissingCells()
    }
    
    //MARK: - View transformation (Table <-> Collection)
    
    /**
     Wrapper around transformViewWithCompletion for UIBarButton implementation.
     */
    open func transformView() {
        transformViewWithCompletion() { ()->Void in }
    }
    
    /**
     Rearranges the scrollView's layout.
     
     - DISCUSSION: Rearranging items when deep in view - the animation could be much nicer (sometimes, when deep in the view, tha animation makes everything "slide away" and then it magically shows everything that's supposed to be visible) - maybe scroll to point where the top item should be after the view is rearranged.
     
     :param: completionClosure
     */
    fileprivate func transformViewWithCompletion(_ completionClosure:@escaping () -> Void) {
        let collectionClosure = {() -> T2GLayoutMode in
            let indicesExtremes = self.scrollView.firstAndLastVisibleTags()
            if indicesExtremes.highest != Int.min && indicesExtremes.lowest != Int.max {
                var from = (indicesExtremes.highest) + 1
                
                if from > self.scrollView.totalCellCount() {
                    from = self.scrollView.totalCellCount() - 1 + T2GViewTags.cellConstant
                }
                
                var to = (indicesExtremes.highest) + 10
                if to > self.scrollView.totalCellCount() {
                    to = self.scrollView.totalCellCount() - 1 + T2GViewTags.cellConstant
                }
                
                for index in from...to {
                    self.insertRowWithTag(index)
                }
            }
            return .collection
        }
        
        let mode = scrollView.layoutMode == .collection ? T2GLayoutMode.table : collectionClosure()
        scrollView.adjustContentSize(mode)
        displayMissingCells()
        displayMissingCells(mode)
        
        UIView.animate(withDuration: 0.8, animations: { () -> Void in
            
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
            
        }, completion: { (_) -> Void in
            self.scrollView.performSubviewCleanup()
            self.displayMissingCells()
            completionClosure()
        }) 
        
        scrollView.layoutMode = mode
    }
    
    //MARK: - Rotation handler
    
    /**
     Makes sure that all subviews get properly resized (Table) or placed (Collection) during rotation. Forces navigation controller menu to close when opened.
     
     :param: toInterfaceOrientation Default Cocoa API - The new orientation for the user interface.
     :param: duration Default Cocoa API - The duration of the pending rotation, measured in seconds.
     */
    override open func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willAnimateRotation(to: toInterfaceOrientation, duration: duration)
        
        let indicesExtremes = scrollView.firstAndLastVisibleTags()
        
        if indicesExtremes.lowest != Int.max || indicesExtremes.highest != Int.min {
            let from = (indicesExtremes.highest) + 1
            let to = (indicesExtremes.highest) + 10
            if (to - T2GViewTags.cellConstant) < scrollView.totalCellCount() {
                for index in from...to {
                    insertRowWithTag(index)
                }
            }
        }
        UIView.animate(withDuration: 0.8, animations: { () -> Void in
            if let bar = self.view.viewWithTag(T2GViewTags.editingModeToolbar) as? UIToolbar {
                let height: CGFloat = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 35.0 : 44.0
                bar.frame = CGRect(x: 0, y: self.view.frame.size.height - height, width: self.view.frame.size.width, height: height)
            }
            self.updateScrollView()
        }, completion: { (_) -> Void in
            self.scrollView.adjustContentSize()
            self.scrollView.performSubviewCleanup()
        }) 
    }
    
    /**
     Makes sure to display all missing cells after the rotation ended.
     
     :param: fromInterfaceOrientation Default Cocoa API - The old orientation of the user interface.
     */
    override open func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        displayMissingCells()
    }

    //MARK: - ScrollView delegate
    
    /**
     Helper method after the scrollView has snapped back (most likely after UIRefreshControl has been pulled). The thing is, that performSubviewCleanup is usually called and the last cells could be missing because they go off-screen during UIRefreshControl's loading. This method makes sure that all cells are properly displayed afterwards.
     */
    override func handleSnapBack() {
        displayMissingCells()
    }
    
    /**
     Performs cleanup of all forgotten subviews that are off-screen.
     
     :param: scrollView Default Cocoa API - The scroll-view object in which the decelerating occurred.
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollView.performSubviewCleanup()
    }
    
    /**
     If the view ended without decelaration it performs cleanup of subviews that are off-screen.
     
     - WARNING: Super must be called if hiding feature of T2GScrollController is desired.
     
     :param: scrollView Default Cocoa API - The scroll-view object that finished scrolling the content view.
     :param: willDecelerate Default Cocoa API - true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
     */
    override open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        if !decelerate {
            self.scrollView.performSubviewCleanup()
        }
    }
    
    /**
     Dynamically deletes and adds rows while scrolling.
     
     - WARNING: Super must be called if hiding feature of T2GScrollController is desired. Fix has been done to handle rotation, not sure what it will do when scrolling fast.
     
     :param: scrollView Default Cocoa API - The scroll-view object in which the scrolling occurred.
     */
    override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let currentOffset = scrollView.contentOffset
        let currentTime = Date.timeIntervalSinceReferenceDate
        var currentSpeed = T2GScrollingSpeed.slow
        
        if(currentTime - lastSpeedOffsetCaptureTime > 0.1) {
            let distance = currentOffset.y - lastSpeedOffset.y
            let scrollSpeed = fabsf(Float((distance * 10) / 1000))
            
            if (scrollSpeed > 6) {
                currentSpeed = .fast
            } else if scrollSpeed > 0.5 {
                currentSpeed = .normal
            }
            
            lastSpeedOffset = currentOffset
            lastSpeedOffsetCaptureTime = currentTime
        }
        
        let extremes = self.scrollView.firstAndLastVisibleTags()
        
        if extremes.lowest != Int.max || extremes.highest != Int.min {
            let startingPoint = scrollDirection == .up ? extremes.lowest : extremes.highest
            let endingPoint = scrollDirection == .up ? extremes.highest : extremes.lowest
            let edgeCondition = scrollDirection == .up ? T2GViewTags.cellConstant : self.scrollView.totalCellCount() + T2GViewTags.cellConstant - 1
            
            let startingPointIndexPath = self.scrollView.indexPathForCell(extremes.lowest)
            let endingPointIndexPath = self.scrollView.indexPathForCell(extremes.highest)
            
            insertDelimiterForSection(self.scrollView.layoutMode, section: (startingPointIndexPath as NSIndexPath).section)
            insertDelimiterForSection(self.scrollView.layoutMode, section: (endingPointIndexPath as NSIndexPath).section)
            
            if let cell = scrollView.viewWithTag(endingPoint) as? T2GCell , !scrollView.bounds.intersects(cell.frame) {
                cell.removeFromSuperview()
            }

            displayMissingCells()
//            if let edgeCell = scrollView.viewWithTag(startingPoint) as? T2GCell {
//                if scrollView.bounds.intersects(edgeCell.frame) && startingPoint != edgeCondition {
//                    let firstAddedTag = addRowsWhileScrolling(scrollDirection, startTag: startingPoint)
//                    if (currentSpeed == .fast || currentSpeed == .normal) && firstAddedTag != edgeCondition {
//                        let secondAddedTag = addRowsWhileScrolling(scrollDirection, startTag: firstAddedTag)
//                        if (currentSpeed == .fast) && secondAddedTag != edgeCondition {
//                            let thirdAddedTag = addRowsWhileScrolling(scrollDirection, startTag: secondAddedTag)
//                            if (currentSpeed == .fast || self.scrollView.layoutMode == .collection) && thirdAddedTag != edgeCondition {
//                                //                                let fourthAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: secondAddedTag)
//                            }
//                        }
//                    }
//                }
//            } else {
//                displayMissingCells()
//            }
        } else {
            displayMissingCells()
        }
    }
    
    /**
     Checks and displays all cells that should be displayed.
     
     :param: mode T2GLayoutMode for which the supposedly displayed cells should be calculated. Optional value - if nothing is passed, current layout is used.
     */
    func displayMissingCells(_ mode: T2GLayoutMode? = nil) {
        let m = mode ?? scrollView.layoutMode
        
        let indices = scrollView.indicesForVisibleCells(m)
        for index in indices {
            insertRowWithTag(index + T2GViewTags.cellConstant, animated: true)
        }
    }
    
    /**
     Adds rows while scrolling. Handles edge situations.
     
     :param: direction T2GScrollDirection defining which way is the scrollView being scrolled.
     :param: startTag Integer value representing the starting tag from which the next should be calculated - if direction is Up it is the TOP cell, if Down it is the BOTTOM cell in the scrollView.
     :returns: Integer value of the last added tag to the scrollView.
     */
    func addRowsWhileScrolling(_ direction: T2GScrollDirection, startTag: Int) -> Int {
//        let multiplier = direction == .up ? -1 : 1
//        let firstTag = startTag + (1 * multiplier)
//        let secondTag = startTag + (2 * multiplier)
//        let thirdTag = startTag + (3 * multiplier)
//        
//        let firstAdditionalCondition = direction == .up ? secondTag - T2GViewTags.cellConstant > 0 : secondTag - T2GViewTags.cellConstant < (scrollView.totalCellCount() - 1)
//        let secondAdditionalCondition = direction == .up ? thirdTag - T2GViewTags.cellConstant > 0 : thirdTag - T2GViewTags.cellConstant < (scrollView.totalCellCount() - 1)
//        
//        var lastTag = insertRowWithTag(firstTag)
//        
//        if self.scrollView.layoutMode == .collection {
//            if firstAdditionalCondition {
//                lastTag = insertRowWithTag(secondTag)
//                
//                if secondAdditionalCondition {
//                    lastTag = insertRowWithTag(thirdTag)
//                }
//            }
//        }
//        
//        return lastTag
        return 0
    }
    
    
}

//MARK: - T2GCell delegate
extension T2GViewController: T2GCellDelegate {
    /**
     Closes other cell in case it was open before this cell started being swiped.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the currently swiped cell.
     */
    func cellStartedSwiping(_ tag: Int) {
        if openCellTag != -1 && openCellTag != tag {
            let cell = view.viewWithTag(openCellTag) as? T2GCell
            cell?.closeCell()
        }
    }
    
    /**
     Redirects the call to the delegate to handle the event of cell selection.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the selected cell.
     */
    func didSelectCell(_ tag: Int) {
        delegate.didSelectCellAtIndexPath(scrollView.indexPathForCell(tag))
    }
    
    
    func didCheckCell(_ tag: Int) {
        delegate.didCheckCellAtIndexPath(scrollView.indexPathForCell(tag))
    }
    
    func didUncheckCell(_ tag: Int) {
        delegate.didUncheckCellAtIndexPath(scrollView.indexPathForCell(tag))
    }
    
    /**
     Sets the tag for the currently open cell to be able to close it when another cell gets swiped.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the opened cell.
     */
    func didCellOpen(_ tag: Int) {
        if openCellTag != -1 && openCellTag != tag {
            let cell = view.viewWithTag(openCellTag) as? T2GCell
            cell?.closeCell()
        }
        openCellTag = tag
        delegate.backGestureStatus(false)
    }
    
    /**
     Resets the tag for currently open cell to default (-1) value.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag
     */
    func didCellClose(_ tag: Int) {
        delegate.backGestureStatus(true)
    }
    
    /**
     Redirects the call to the delegate to handle the event of drawer button selection.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the cell where the drawer button has been selected.
     :param: index Integer value representing the index of the button that has been selected.
     */
    func didSelectButton(_ tag: Int, index: Int) {
        delegate.didSelectDrawerButtonAtIndex(scrollView.indexPathForCell(tag), buttonIndex: index)
    }
    
    func didLongPressCell(_ tag: Int) {
        if !isEditingModeActive {
            toggleEdit()
        }
    }
}
