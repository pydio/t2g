//
//  T2GDragAndDropView.swift
//  SplitView
//
//  Created by Michal Švácha on 20/04/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

protocol T2GDragAndDropOwnerDelegate {
    func addGestureRecognizerToView(recognizer: UILongPressGestureRecognizer)
}

protocol T2GDragAndDropDelegate {
    func didMove(tag: Int, frame: CGRect)
    func didDrop(cell: T2GDragAndDropView)
}

class T2GDragAndDropView: UIView {
    var ownerDelegate: T2GDragAndDropOwnerDelegate?
    var draggableDelegate: T2GDragAndDropDelegate?
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var lastDraggedLocation:CGPoint = CGPointMake(0, 0)
    var origin:CGPoint = CGPointMake(0, 0)
    
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
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        if self.viewWithTag(T2GViewTags.checkboxButton.rawValue) == nil {
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
