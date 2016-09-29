//
//  T2GDragAndDropView.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 20/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
Protocol to add the long press gesture recognizer to whoever owns this view. Could be even this object, depends on custom needs.
*/
protocol T2GDragAndDropOwnerDelegate: class {
    /**
    Gets called when draggable boolean variable is set to true. Passes long press gesture recognizer to be added to the drop owner delegate.
    
    :param: recognizer Long press gesture created when draggable flag is set to true. Should be added to the owner of this view.
    */
    func addGestureRecognizerToView(_ recognizer: UILongPressGestureRecognizer)
}

/**
Protocol for drag and drop delegate to inform that item has been moved or dropped.
*/
protocol T2GDragAndDropDelegate: class {
    /**
    Informs delegate that frame has been changed while being dragged.
    
    :param: tag Tag of the dragged view.
    :param: frame Frame of the dragged view (for potential overlapping detection).
    */
    func didMove(_ tag: Int, frame: CGRect)
    
    /**
    Informs delegate that the view has been dropped - the long press gesture (followed by swiping movement has come to an end).
    
    :param: cell The whole view in case the delegte wants to modify or remove it.
    */
    func didDrop(_ view: T2GDragAndDropView)
}

/**
Custom UIView with drag and drop implementation. Activated on long press.
*/
open class T2GDragAndDropView: UIView {
    weak var ownerDelegate: T2GDragAndDropOwnerDelegate?
    weak var draggableDelegate: T2GDragAndDropDelegate?
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var lastDraggedLocation:CGPoint = CGPoint(x: 0, y: 0)
    var origin:CGPoint = CGPoint(x: 0, y: 0)
    
    /// Activating flag for drag and drop
    open var draggable: Bool = false {
        didSet {
            if draggable {
                self.lastDraggedLocation = self.frame.origin
                
                if self.longPressGestureRecognizer == nil {
                    self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(T2GDragAndDropView.handleLongPress(_:)))
                    self.longPressGestureRecognizer!.minimumPressDuration = 1.5
                    self.ownerDelegate?.addGestureRecognizerToView(self.longPressGestureRecognizer!)
                }
            } else {
                if let longPress = self.longPressGestureRecognizer {
                    self.lastDraggedLocation = CGPoint(x: 0, y: 0)
                    
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
    func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if self.viewWithTag(T2GViewTags.checkboxButton) == nil {
            if sender.state == UIGestureRecognizerState.began {
                self.superview?.bringSubview(toFront: self)
                self.origin = self.frame.origin
                self.lastDraggedLocation = sender.location(in: self.superview)
                
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    let transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    self.transform = transform
                }, completion: { (_) -> Void in
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.transform = transform
                    }, completion: { (_) -> Void in
                        // Long press activated
                    })
                })
            }
            
            if sender.state == UIGestureRecognizerState.changed {
                let point = sender.location(in: self.superview)
                var center = self.center
                center.x = (center.x + (point.x - self.lastDraggedLocation.x))
                center.y = (center.y + (point.y - self.lastDraggedLocation.y))
                self.center = center
                self.lastDraggedLocation = point
                self.draggableDelegate?.didMove(self.tag, frame: self.frame)
            }
            
            if sender.state == .ended {
                self.draggableDelegate?.didDrop(self)
            }
        }
    }

}
