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
protocol T2GViewControllerDelegate {
    /// View methods
    /**
     Enable/Disable Swipe back action see in NodeViewController for more details.
     
     :param: enabled: boolean that indicate if the user can swipe back on the previous view controller.
     */
    func backGestureStatus(enabled: Bool)
    
    /**
    Creates and returns a T2GCell object ready to be put in the scrollView.
    
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    :param: frame Expected frame for the cell.
    :returns:
    */
    func cellForIndexPath(indexPath: NSIndexPath, frame: CGRect) -> T2GCell
    
    /**
    Returns the header text for section delimiter.
    
    :param: section Integer value defining number of cells in given section.
    :returns: Optional String to be set in the UILabel of T2GDelimiterView
    */
    func titleForHeaderInSection(section: Int) -> String?
    
    /**
    Gets called when cell needs an update.
    
    :param: cell T2GCell view to be updated.
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    */
    func updateCellForIndexPath(cell: T2GCell, indexPath: NSIndexPath)
    
    /// Action methods
    
    /**
    Gets called when cell is tapped.
    
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    */
    func didSelectCellAtIndexPath(indexPath: NSIndexPath)
    
    /**
    Gets called when button in the drawer is tapped.
    
    :param: indexPath NSIndexPath object with precise location of the cell (row and section).
    :param: buttonIndex Index of the button in the drawer - indexed from right to left starting with 0.
    */
    func didSelectDrawerButtonAtIndex(indexPath: NSIndexPath, buttonIndex: Int)
    
    /**
    Gets called when a cell will be removed from the scrollView.
    
    :param: NSIndexPath object with precise location of the cell (row and section).
    */
    func willRemoveCellAtIndexPath(indexPath: NSIndexPath)
    
    /**
    Unused at the moment. Planned for future development.
    */
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    
    /**
    Unused at the moment. Planned for future development.
    */
    func willDeselectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath?
    
    /**
     Unused at the moment. Planned for future development.
     */
    func didDeselectCellAtIndexPath(indexPath: NSIndexPath)
}

/**
 Protocol for delegate handling drop event.
 */
protocol T2GDropDelegate {
    /**
     Gets called when a T2GCell gets dropped on top of another cell. This method should handle the event of success/failure.
     
     :param: cell Dragged cell.
     :param: onCell Cell on which the dragged cell has been dropped.
     :param: completion Completion closure to be performed in case the drop has been successful.
     :param: failure Failure closure to be performed in case the drop has not been successful.
     */
    func didDropCell(cell: T2GCell, onCell: T2GCell, completion: () -> Void, failure: () -> Void)
}

/**
 Enum defining scrolling speed. Used for deciding how fast should rows be added in method addRowsWhileScrolling.
 */
private enum T2GScrollingSpeed {
    case Slow
    case Normal
    case Fast
}

/**
 Custom view controller class handling the whole T2G environment (meant to be overriden for customizations).
 */
class T2GViewController: T2GScrollController, T2GCellDelegate {
    var scrollView: T2GScrollView!
//    var actionView: MaterialView!
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
            var count = self.scrollView.visibleCellCount()
            let totalCells = self.scrollView.totalCellCount()
            count = count > totalCells ? totalCells : count
            
            for index in 0..<count {
                self.insertRowWithTag(index + T2GViewTags.cellConstant)
            }
            self.scrollView.adjustContentSize()
        }
    }
    var dropDelegate: T2GDropDelegate?
    
    /**
    Sets slight delay for VC push in case T2GNaviViewController is present. Then adds scrollView to the view with constraints such that the scrollView is always the same size as the superview.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationCtr = navigationController as? T2GNaviViewController {
            navigationCtr.segueDelay = 0.16
        }
        prepareScrollView()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    private func prepareScrollView() {
        scrollView = T2GScrollView()
        scrollView.backgroundColor = UIColor(red: 238.0/255.0, green: 233.0/255.0, blue: 233/255.0, alpha: 1.0)
        scrollView.adjustContentSize()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let horizontalConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraintTop = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let verticalConstraintBottom = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraintTop)
        view.addConstraint(verticalConstraintBottom)
        let widthConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        view.addConstraint(widthConstraint)
        view.addConstraint(heightConstraint)
    }
    
    private func updateScrollView() {
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
     Sets the scrollView delegate to be self. Makes sure that all cells that should be visible are visible. Also checks if T2GNavigationBarTitle is present to form appearance for Normal and Highlighted state.
     
     :param: animated Default Cocoa API - If YES, the view was added to the window using an animation.
     */
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Reloads the whole scrollView - does NOT delete everything, rather calls update on every visible cell.
     */
    func reloadScrollView() {
        for view in self.scrollView.subviews {
            if let cell = view as? T2GCell {
                self.delegate.updateCellForIndexPath(cell, indexPath: self.scrollView.indexPathForCell(cell.tag))
            }
        }
        self.displayMissingCells()
        self.scrollView.adjustContentSize()
    }
    
    func refreshScrollView() {
        self.clearScrollView()
        self.displayMissingCells()
        self.scrollView.adjustContentSize()
    }
    /**
     Clear the scrollview by removing each subview inside
     */
    
    func clearScrollView() {
        for view in self.scrollView.subviews {
            if let cell = view as? UIView {
                if cell.tag != 222222 { //Check if subview is not the refreshControl
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
    func toggleEdit() {
        if self.openCellTag != -1 {
            if let view = self.scrollView!.viewWithTag(self.openCellTag) as? T2GCell {
                view.closeCell()
            }
        }
        
        self.isEditingModeActive = !self.isEditingModeActive
        
        for view in self.scrollView.subviews {
            if let cell = view as? T2GCell {
                let isSelected = self.editingModeSelection[cell.tag - T2GViewTags.cellConstant] ?? false
                cell.toggleMultipleChoice(self.isEditingModeActive, mode: self.scrollView.layoutMode, selected: isSelected, animated: true)
            }
        }
        
        self.toggleToolbar()
    }
    
    /**
     Closes the cell at the given indexPath. Does nothing if the cell isn't visible anymore.
     
     :param: indexPath NSIndexPath of the given cell.
     */
    func closeCell(indexPath: NSIndexPath) {
        let index = self.scrollView.indexForIndexPath(indexPath)
        
        if let cell = self.scrollView.viewWithTag(index + T2GViewTags.cellConstant) as? T2GCell {
            cell.closeCell()
        }
    }
    
    /**
     Not implemented yet
     
     - DISCUSSION: This method probably shouldn't be here at all.
     */
    func moveBarButtonPressed() {
        print("Not implemented yet.")
    }
    
    /**
     Gets called when delete button in the toolbar has been pressed and therefore multiple rows should be deleted. Animates all the visible/potentinally visible after the animation, notifies the delegate before doing so to adjust the model so the new cell frames could be calculated.
     */
    func deleteBarButtonPressed() {
        var indexPaths: [NSIndexPath] = []
        
        for key in self.editingModeSelection.keys {
            if self.editingModeSelection[key] == true {
                indexPaths.append(self.scrollView.indexPathForCell(key + T2GViewTags.cellConstant))
            }
        }
        
        self.removeRowsAtIndexPaths(indexPaths.sort({$0.section == $1.section ? $0.row < $1.row : $0.section < $1.section}), notifyDelegate: true)
        self.editingModeSelection = [Int : Bool]()
    }
    
    /**
    Shows toolbar with Move and Delete buttons.
    
    - DISCUSSION: Another TODO for making it more modular.
    */
    func toggleToolbar() {
        if let bar = self.view.viewWithTag(T2GViewTags.editingModeToolbar) {
            bar.removeFromSuperview()
            self.scrollView.adjustContentSize()
        } else {
            let bar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
            bar.tag = T2GViewTags.editingModeToolbar
            bar.translucent = false
            
            let leftItem = UIBarButtonItem(title: "Move", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(T2GViewController.moveBarButtonPressed))
            let rightItem = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(T2GViewController.deleteBarButtonPressed))
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
    
    //MARK: - CRUD methods
    
    /**
    Inserts delimiter for the given section.
    
    :param: mode T2GLayoutMode for which the delimiter's frame should be calculated.
    :param: section Integer value representing the section of the delimiter to ask for the title accordingly.
    */
    func insertDelimiterForSection(mode: T2GLayoutMode, section: Int) {
        if self.scrollView.viewWithTag(section + 1) as? T2GDelimiterView == nil {
            let name = self.delegate.titleForHeaderInSection(section) ?? ""
            
            let delimiter = T2GDelimiterView(frame: self.scrollView.frameForDelimiter(mode, section: section), title: name)
            delimiter.tag = section + 1
            
            self.scrollView.addSubview(delimiter)
        }
    }
    
    
    /**
     Inserts cells in given indexPaths.
     
     :param: indexPaths
     */
    func insertRowsAtIndexPath(indexPaths: [NSIndexPath]) {
        for i in indexPaths {
            insertRowAtIndexPath(i)
        }
    }
    
    /**
    Inserts cell in given indexPath.
    
    :param: indexPath
    */
    func insertRowAtIndexPath(indexPath: NSIndexPath) {
        let totalIndex = self.scrollView.indexForIndexPath(indexPath)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
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
            UIView.animateWithDuration(0.3, animations: { () -> Void in
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
    private func insertRowWithTag(tag: Int, animated: Bool = false) -> Int {
        let indexPath = self.scrollView.indexPathForCell(tag)
        
        if indexPath.row == 0 {
            self.insertDelimiterForSection(self.scrollView.layoutMode, section: indexPath.section)
        }
        
        if let cell = self.scrollView.viewWithTag(tag) {
            return cell.tag
        } else {
            let frame = self.scrollView.frameForCell(indexPath: indexPath)
            let cellView = self.delegate.cellForIndexPath(indexPath, frame: frame)
            cellView.tag = tag
            
            if self.isEditingModeActive {
                let isSelected = self.editingModeSelection[cellView.tag - T2GViewTags.cellConstant] ?? false
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
    
    
    
    func updateRowsAtIndexPaths(indexPaths: [NSIndexPath]) {
        for i in indexPaths {
            updateRowAtIndexPath(i)
        }
    }
    
    func updateRowAtIndexPath(indexPath: NSIndexPath) {
        for view in self.scrollView.subviews {
            if let cell = view as? T2GCell {
                if cell.tag == indexPath.row {
                    self.delegate.updateCellForIndexPath(cell, indexPath: self.scrollView.indexPathForCell(cell.tag))
                }
            }
        }
    }
    
    /**
    Removes rows at given indexPaths. Used even for single row removal.
    
    :param: indexPaths Array of NSIndexPath objects defining the positions of the cells.
    :param: notifyDelegate Boolean flag saying whether or not the delegate should be notified about the removal - maybe the call was performed before the model has been adjusted.
    */
    func removeRowsAtIndexPaths(indexPaths: [NSIndexPath], notifyDelegate: Bool = false) {
        var indices: [Int] = []
        if indexPaths.count == 0 {
            return
        }
        for indexPath in indexPaths {
            indices.append(self.scrollView.indexForIndexPath(indexPath))
        }
        
        
        for idx in indices {
            if let view = self.scrollView!.viewWithTag(idx + T2GViewTags.cellConstant) as? T2GCell {
                view.removeFromSuperview()
            }
        }
        scrollView.adjustContentSize()
        displayMissingCells()
    }
    
    //MARK: - View transformation (Table <-> Collection)
    
    /**
     Wrapper around transformViewWithCompletion for UIBarButton implementation.
     */
    func transformView() {
        self.transformViewWithCompletion() { ()->Void in }
    }
    
    /**
     Rearranges the scrollView's layout.
     
     - DISCUSSION: Rearranging items when deep in view - the animation could be much nicer (sometimes, when deep in the view, tha animation makes everything "slide away" and then it magically shows everything that's supposed to be visible) - maybe scroll to point where the top item should be after the view is rearranged.
     
     :param: completionClosure
     */
    private func transformViewWithCompletion(completionClosure:() -> Void) {
        let collectionClosure = {() -> T2GLayoutMode in
            let indicesExtremes = self.scrollView.firstAndLastVisibleTags()
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
            
            return .Collection
        }
        
        let mode = self.scrollView.layoutMode == .Collection ? T2GLayoutMode.Table : collectionClosure()
        self.scrollView.adjustContentSize(mode)
        self.displayMissingCells()
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
            self.scrollView.performSubviewCleanup()
            self.displayMissingCells()
            completionClosure()
        }
        
        self.scrollView.layoutMode = mode
    }
    
    //MARK: - Rotation handler
    
    /**
     Makes sure that all subviews get properly resized (Table) or placed (Collection) during rotation. Forces navigation controller menu to close when opened.
     
     :param: toInterfaceOrientation Default Cocoa API - The new orientation for the user interface.
     :param: duration Default Cocoa API - The duration of the pending rotation, measured in seconds.
     */
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        
        if let navCtr = self.navigationController as? T2GNaviViewController {
            navCtr.toggleBarMenu(true)
        }
        
        let indicesExtremes = self.scrollView.firstAndLastVisibleTags()
        
        if indicesExtremes.lowest != Int.max || indicesExtremes.highest != Int.min {
            let from = (indicesExtremes.highest) + 1
            let to = (indicesExtremes.highest) + 10
            if (to - T2GViewTags.cellConstant) < self.scrollView.totalCellCount() {
                for index in from...to {
                    self.insertRowWithTag(index)
                }
            }
        }
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            if let bar = self.view.viewWithTag(T2GViewTags.editingModeToolbar) as? UIToolbar {
                let height: CGFloat = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 35.0 : 44.0
                bar.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)
            }
            self.updateScrollView()
        }) { (_) -> Void in
            self.scrollView.adjustContentSize()
            self.scrollView.performSubviewCleanup()
        }
    }
    
    /**
     Makes sure to display all missing cells after the rotation ended.
     
     :param: fromInterfaceOrientation Default Cocoa API - The old orientation of the user interface.
     */
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.displayMissingCells()
    }
    
    // MARK: -CopyMoveView delegate
    
    func copyButtonSelected() {
    }
    
    func moveButtonSelected() {
    }
    
    func cancelButtonSelected() {
    }

    //MARK: - ScrollView delegate
    
    /**
     Helper method after the scrollView has snapped back (most likely after UIRefreshControl has been pulled). The thing is, that performSubviewCleanup is usually called and the last cells could be missing because they go off-screen during UIRefreshControl's loading. This method makes sure that all cells are properly displayed afterwards.
     */
    override func handleSnapBack() {
        self.displayMissingCells()
    }
    
    /**
     Performs cleanup of all forgotten subviews that are off-screen.
     
     :param: scrollView Default Cocoa API - The scroll-view object in which the decelerating occurred.
     */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollView.performSubviewCleanup()
    }
    
    /**
     If the view ended without decelaration it performs cleanup of subviews that are off-screen.
     
     - WARNING: Super must be called if hiding feature of T2GScrollController is desired.
     
     :param: scrollView Default Cocoa API - The scroll-view object that finished scrolling the content view.
     :param: willDecelerate Default Cocoa API - true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
     */
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let currentOffset = scrollView.contentOffset
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var currentSpeed = T2GScrollingSpeed.Slow
        
        if(currentTime - self.lastSpeedOffsetCaptureTime > 0.1) {
            let distance = currentOffset.y - self.lastSpeedOffset.y
            let scrollSpeed = fabsf(Float((distance * 10) / 1000))
            
            if (scrollSpeed > 6) {
                currentSpeed = .Fast
            } else if scrollSpeed > 0.5 {
                currentSpeed = .Normal
            }
            
            self.lastSpeedOffset = currentOffset
            self.lastSpeedOffsetCaptureTime = currentTime
        }
        
        let extremes = self.scrollView.firstAndLastVisibleTags()
        
        if extremes.lowest != Int.max || extremes.highest != Int.min {
            let startingPoint = self.scrollDirection == .Up ? extremes.lowest : extremes.highest
            let endingPoint = self.scrollDirection == .Up ? extremes.highest : extremes.lowest
            let edgeCondition = self.scrollDirection == .Up ? T2GViewTags.cellConstant : self.scrollView.totalCellCount() + T2GViewTags.cellConstant - 1
            
            let startingPointIndexPath = self.scrollView.indexPathForCell(extremes.lowest)
            let endingPointIndexPath = self.scrollView.indexPathForCell(extremes.highest)
            
            self.insertDelimiterForSection(self.scrollView.layoutMode, section: startingPointIndexPath.section)
            self.insertDelimiterForSection(self.scrollView.layoutMode, section: endingPointIndexPath.section)
            
            if let cell = scrollView.viewWithTag(endingPoint) as? T2GCell where !CGRectIntersectsRect(scrollView.bounds, cell.frame) {
                cell.removeFromSuperview()
            }
            
            if let edgeCell = scrollView.viewWithTag(startingPoint) as? T2GCell {
                if CGRectIntersectsRect(scrollView.bounds, edgeCell.frame) && startingPoint != edgeCondition {
                    let firstAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: startingPoint)
                    if (currentSpeed == .Fast || currentSpeed == .Normal) && firstAddedTag != edgeCondition {
                        let secondAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: firstAddedTag)
                        if (currentSpeed == .Fast) && secondAddedTag != edgeCondition {
                            let thirdAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: secondAddedTag)
                            if (currentSpeed == .Fast || self.scrollView.layoutMode == .Collection) && thirdAddedTag != edgeCondition {
                                //                                let fourthAddedTag = self.addRowsWhileScrolling(self.scrollDirection, startTag: secondAddedTag)
                            }
                        }
                    }
                }
            } else {
                self.displayMissingCells()
            }
        } else {
            self.displayMissingCells()
        }
    }
    
    /**
     Checks and displays all cells that should be displayed.
     
     :param: mode T2GLayoutMode for which the supposedly displayed cells should be calculated. Optional value - if nothing is passed, current layout is used.
     */
    func displayMissingCells(mode: T2GLayoutMode? = nil) {
        let m = mode ?? self.scrollView.layoutMode
        
        let indices = self.scrollView.indicesForVisibleCells(m)
        for index in indices {
            self.insertRowWithTag(index + T2GViewTags.cellConstant, animated: true)
        }
    }
    
    /**
     Adds rows while scrolling. Handles edge situations.
     
     :param: direction T2GScrollDirection defining which way is the scrollView being scrolled.
     :param: startTag Integer value representing the starting tag from which the next should be calculated - if direction is Up it is the TOP cell, if Down it is the BOTTOM cell in the scrollView.
     :returns: Integer value of the last added tag to the scrollView.
     */
    func addRowsWhileScrolling(direction: T2GScrollDirection, startTag: Int) -> Int {
        let multiplier = direction == .Up ? -1 : 1
        let firstTag = startTag + (1 * multiplier)
        let secondTag = startTag + (2 * multiplier)
        let thirdTag = startTag + (3 * multiplier)
        
        let firstAdditionalCondition = direction == .Up ? secondTag - T2GViewTags.cellConstant > 0 : secondTag - T2GViewTags.cellConstant < (self.scrollView.totalCellCount() - 1)
        let secondAdditionalCondition = direction == .Up ? thirdTag - T2GViewTags.cellConstant > 0 : thirdTag - T2GViewTags.cellConstant < (self.scrollView.totalCellCount() - 1)
        
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
    
    /**
     Closes other cell in case it was open before this cell started being swiped.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the currently swiped cell.
     */
    func cellStartedSwiping(tag: Int) {
        if self.openCellTag != -1 && self.openCellTag != tag {
            let cell = self.view.viewWithTag(self.openCellTag) as? T2GCell
            cell?.closeCell()
        }
    }
    
    /**
     Redirects the call to the delegate to handle the event of cell selection.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the selected cell.
     */
    func didSelectCell(tag: Int) {
        self.delegate.didSelectCellAtIndexPath(self.scrollView.indexPathForCell(tag))
    }
    
    /**
     Sets the tag for the currently open cell to be able to close it when another cell gets swiped.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the opened cell.
     */
    func didCellOpen(tag: Int) {
        if self.openCellTag != -1 && self.openCellTag != tag {
            let cell = self.view.viewWithTag(self.openCellTag) as? T2GCell
            cell?.closeCell()
        }
        self.openCellTag = tag
        self.delegate.backGestureStatus(false)
    }
    
    /**
     Resets the tag for currently open cell to default (-1) value.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag
     */
    func didCellClose(tag: Int) {
        self.delegate.backGestureStatus(true)
    }
    
    /**
     Redirects the call to the delegate to handle the event of drawer button selection.
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag of the cell where the drawer button has been selected.
     :param: index Integer value representing the index of the button that has been selected.
     */
    func didSelectButton(tag: Int, index: Int) {
        self.delegate.didSelectDrawerButtonAtIndex(self.scrollView.indexPathForCell(tag), buttonIndex: index)
    }
    
    /**
     Saves the total index of the selected cell so it can reproduce the selection when the scrollView's content is long and gets deleted/added again (dynamic loading). Also serves as the full list of cells to be acted upon when toolbar button gets pressed (currently only delete).
     
     For description of the function header, see T2GCellDelegate protocol definition in T2GCell class.
     
     :param: tag Integer value representing the tag value of the cell whose checkbox has been pressed.
     :param: selected Boolean value representing whether the checkbox is selected or not.
     */
    func didSelectMultipleChoiceButton(tag: Int, selected: Bool) {
        self.editingModeSelection[tag - T2GViewTags.cellConstant] = selected
    }
    
}