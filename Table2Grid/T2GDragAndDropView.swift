//
//  T2GDragAndDropView.swift
//  SplitView
//
//  Created by Michal Švácha on 20/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Protocol to add the long press gesture recognizer to whoever owns this view. Could be even this object, depends on custom needs.
*/
protocol T2GDragAndDropOwnerDelegate {
    /**
    Gets called when draggable boolean variable is set to true. Passes long press gesture recognizer to be added to the drop owner delegate.
    
    :param: recognizer Long press gesture created when draggable flag is set to true. Should be added to the owner of this view.
    */
    func addGestureRecognizerToView(recognizer: UILongPressGestureRecognizer)
}

/**
Protocol for drag and drop delegate to inform that item has been moved or dropped.
*/
protocol T2GDragAndDropDelegate {
    /**
    Informs delegate that frame has been changed while being dragged.
    
    :param: tag Tag of the dragged view.
    :param: frame Frame of the dragged view (for potential overlapping detection).
    */
    func didMove(tag: Int, frame: CGRect)
    
    /**
    Informs delegate that the view has been dropped - the long press gesture (followed by swiping movement has come to an end).
    
    :param: cell The whole view in case the delegte wants to modify or remove it.
    */
    func didDrop(view: T2GDragAndDropView)
}

/**
Custom UIView with drag and drop implementation. Activated on long press.
*/
class T2GDragAndDropView: UIView {
    var ownerDelegate: T2GDragAndDropOwnerDelegate?
    var draggableDelegate: T2GDragAndDropDelegate?
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var lastDraggedLocation:CGPoint = CGPointMake(0, 0)
    var origin:CGPoint = CGPointMake(0, 0)
    
    /// Activating flag for drag and drop
    var draggable: Bool = false {
        didSet {
            if draggable {
                self.lastDraggedLocation = self.frame.origin
                
                if self.longPressGestureRecognizer == nil {
                    self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
                    self.longPressGestureRecognizer!.minimumPressDuration = 1.5
                    self.ownerDelegate?.addGestureRecognizerToView(self.longPressGestureRecognizer!)
                }
            } else {
                if let longPress = self.longPressGestureRecognizer {
                    self.lastDraggedLocation = CGPointMake(0, 0)
                    
                    self.removeGestureRecognizer(longPress)
                    self.longPressGestureRecognizer = nil
                }
            }
        }
    }
    
    /**
    Long press handler - animates the view (zoom in and out to signal change of its state) and then 'releases' the view to drag around. When drag has been finished, delegate method didDrop gets called to handle next steps.
    
    :param: sender The long press gesture that is created when draggable flag is set to true.
    */
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        if self.viewWithTag(T2GViewTags.checkboxButton) == nil {
            if sender.state == UIGestureRecognizerState.Began {
                self.superview?.bringSubviewToFront(self)
                self.origin = self.frame.origin
                self.lastDraggedLocation = sender.locationInView(self.superview)
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    let transform = CGAffineTransformMakeScale(1.1, 1.1)
                    self.transform = transform
                }, completion: { (_) -> Void in
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        let transform = CGAffineTransformMakeScale(1.0, 1.0)
                        self.transform = transform
                    }, completion: { (_) -> Void in
                        // Long press activated
                    })
                })
            }
            
            if sender.state == UIGestureRecognizerState.Changed {
                let point = sender.locationInView(self.superview)
                var center = self.center
                center.x = (center.x + (point.x - self.lastDraggedLocation.x))
                center.y = (center.y + (point.y - self.lastDraggedLocation.y))
                self.center = center
                self.lastDraggedLocation = point
                self.draggableDelegate?.didMove(self.tag, frame: self.frame)
            }
            
            if sender.state == .Ended {
                self.draggableDelegate?.didDrop(self)
            }
        }
    }

}
