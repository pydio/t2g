//
//  T2GCell.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 20/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import Foundation
import UIKit

protocol T2GCellDelegate {
    func cellStartedSwiping(tag:Int)
    func didCellOpen(tag: Int)
    func didCellClose(tag: Int)
}

private enum T2GCellSwipeDirection {
    case Right
    case Left
}

class T2GCell: UIView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView?
    var backgroundView: UIView?
    
    var delegate: T2GCellDelegate?
    
    var imageView: UIView?
    var headerLabel: UILabel?
    var detailLabel: UILabel?
    
    private var swipeDirection: T2GCellSwipeDirection = .Left
    
    var lastContentOffset: CGFloat = 0
    
    convenience init(header: String, detail: String, frame: CGRect, mode: T2GLayoutMode) {
        self.init(frame: frame)
        
        self.backgroundColor = UIColor.yellowColor()
        let size = CGFloat(16)
        let margin = (self.frame.size.width - CGFloat(4 * size)) / 5.0
        let y = (self.frame.size.height - size) / 2.0
        
        for index in 0...3 {
            let x = margin + (CGFloat(index) * (size + margin))
            let view = T2GCellButton(frame: CGRectMake(x, y, size, size))
            view.tag = 70 + index
            view.normalBackgroundColor = .redColor()
            view.highlightedBackgroundColor = .blackColor()
            view.setup()
            self.addSubview(view)
        }
        
        self.scrollView = UIScrollView(frame: CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height + 2))
        self.scrollView!.backgroundColor = .clearColor()
        self.scrollView!.showsHorizontalScrollIndicator = false
        self.scrollView!.bounces = false
        self.scrollView!.delegate = self
    
        self.backgroundView = UIView(frame: CGRectMake(0, 0, self.frame.size.width + 2, self.frame.size.height + 2))
        self.backgroundView!.backgroundColor = .grayColor()
        self.scrollView!.addSubview(self.backgroundView!)
        
        self.scrollView!.contentSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height)
        
        //let imageFrame = CGRectMake(0, 0, self.frame.height + 2, self.frame.height + 2)
        let imageFrame = CGRectMake(0, 0, 64 + 2, 64 + 2)
        self.imageView = UIView(frame: imageFrame)
        self.imageView!.backgroundColor = .blackColor()
        self.backgroundView!.addSubview(self.imageView!)
        
        let dimensions = self.framesForLabels(frame)
        
        self.headerLabel = UILabel(frame: dimensions.header)
        self.headerLabel!.backgroundColor = .blackColor()
        self.headerLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        self.headerLabel!.font = UIFont.boldSystemFontOfSize(13)
        self.headerLabel!.textColor = .whiteColor()
        self.headerLabel!.text = header //"Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        self.backgroundView!.addSubview(self.headerLabel!)
        
        self.detailLabel = UILabel(frame: dimensions.detail)
        self.detailLabel!.backgroundColor = .blackColor()
        self.detailLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        self.detailLabel!.font = UIFont.systemFontOfSize(11)
        self.detailLabel!.textColor = .whiteColor()
        self.detailLabel!.text = detail //"Lorem ipsum dolor sit amet."
        self.backgroundView!.addSubview(self.detailLabel!)
        
        self.addSubview(self.scrollView!)
        
        if mode == .Collection {
            self.setFrame2(.Collection, frame: self.frame)
        }
    }
    
    func rearrangeButtons(mode: T2GLayoutMode) {
        if mode == .Table {
            let size = CGFloat(16)
            let margin = (self.frame.size.width - CGFloat(4 * size)) / 5.0
            let y = (self.frame.size.height - size) / 2.0
            
            for index in 0...3 {
                let x = margin + (CGFloat(index) * (size + margin))
                let view = self.viewWithTag(70 + index)! as T2GCellButton
                view.minOriginCoord = CGPointMake(x, y)
                view.frame = CGRectMake(x, y, size, size)
            }
            
        } else {
            let coords = self.coordinatesForSquaredLayouts(4)
            let size = CGFloat(16)
            
            for index in 0...3 {
                let origin = coords[index]
                let view = self.viewWithTag(70 + index)! as T2GCellButton
                view.minOriginCoord = origin
                view.frame = CGRectMake(origin.x, origin.y, size, size)
            }
        }
    }
    
    func coordinatesForSquaredLayouts(buttonCount: Int) -> [CGPoint] {
        var coords: [CGPoint] = []
        
        if buttonCount == 4 {
            let x1 = (50 - 8 - 32) + 8
            let y1 = x1
            coords.append(CGPointMake(CGFloat(x1),CGFloat(y1)))
            
            let x2 = 100 - x1 - 16
            let y2 = y1
            coords.append(CGPointMake(CGFloat(x2),CGFloat(y2)))
            
            let x3 = x1
            let y3 = 100 - 8 - 32 + 8
            coords.append(CGPointMake(CGFloat(x3),CGFloat(y3)))
            
            let x4 = x2
            let y4 = y3
            coords.append(CGPointMake(CGFloat(x4),CGFloat(y4)))
            
        }
        
        return coords
    }
    
    func closeCell() {
        self.moveButtonsInHierarchy(true)
        self.swipeDirection = .Right
        self.handleScrollEnd(self.scrollView!)
    }
    
    func fontSize(frame: CGRect) -> CGFloat {
        let dummyString: NSString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        var dummyFont = UIFont.systemFontOfSize(12)
        
        let size = dummyString.sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(12)])
        let adjustedSize: CGSize = CGSizeMake(CGFloat(ceilf(Float(size.width))), CGFloat(ceilf(Float(size.height))))
        
        let pointsPerPixel = dummyFont.pointSize / size.height
        return frame.size.height * pointsPerPixel
    }
    
    func framesForLabels(frame: CGRect) -> (header: CGRect, detail: CGRect) {
        // Vertical spacing should be like |--H--D--| -> three equal spaces
        
        let headerHeight = frame.size.height * 0.45
        let detailHeight = frame.size.height * 0.30
        let margin = (frame.size.height - (headerHeight + detailHeight)) / 3
        
        let headerWidth = frame.size.width - (frame.size.height + 10) - 10
        let detailWidth = headerWidth * 0.75
        
        let headerFrame = CGRectMake(frame.size.height + 10, margin, headerWidth, headerHeight)
        let detailFrame = CGRectMake(frame.size.height + 10, headerFrame.size.height + (2 * margin), detailWidth, detailHeight)
        
        return (headerFrame, detailFrame)
    }
    
    func setFrame2(mode: T2GLayoutMode, frame: CGRect) {
        if scrollView!.contentOffset.x != 0 {
            self.moveButtonsInHierarchy(true)
            scrollView!.contentOffset.x = 0
        }
        
        self.frame = frame
        self.scrollView!.frame = CGRectMake(-1, -1, frame.size.width + 2, frame.size.height + 2)
        self.backgroundView!.frame = CGRectMake(0, 0, frame.size.width + 2, frame.size.height + 2)
        self.scrollView!.contentSize = CGSizeMake(frame.size.width * 2, frame.size.height)
        
        self.rearrangeButtons(mode)
        
        if let image = self.imageView {
            if mode == .Table {
                image.frame = CGRectMake(0, 0, self.frame.height + 2, self.frame.height + 2)
                
                let dimensions = self.framesForLabels(frame)
                
                self.headerLabel!.frame = dimensions.header
                self.headerLabel!.font = UIFont.boldSystemFontOfSize(13)
                
                self.detailLabel!.frame = dimensions.detail
                self.detailLabel!.alpha = 1
            } else {
                let x = (self.frame.width - image.frame.width) / 2
                let y = frame.size.height - image.frame.height - 6
                image.frame = CGRectMake(x, y, image.frame.width, image.frame.height)
                
                let headerFrame = CGRectMake(0, 0, frame.size.width + 2, y - 2)
                self.headerLabel!.frame = headerFrame
                self.headerLabel!.font = UIFont.boldSystemFontOfSize(11)
                
                self.detailLabel!.alpha = 0
            }
        }
    }
    
    func handleScrollEnd(scrollView: UIScrollView) {
        if self.swipeDirection == .Right {
            scrollView.scrollRectToVisible(CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: true)
            self.delegate?.didCellClose(self.tag)
        } else {
            scrollView.scrollRectToVisible(CGRectMake(self.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: true)
            self.delegate?.didCellOpen(self.tag)
        }
    }
    
    func moveButtonsInHierarchy(hide: Bool) {
        for index in 0...3 {
            let view = self.viewWithTag(70 + index)! as T2GCellButton
            if hide {
                self.sendSubviewToBack(view)
            } else {
                self.bringSubviewToFront(view)
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.delegate?.cellStartedSwiping(self.tag)
        
        self.moveButtonsInHierarchy(true)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.handleScrollEnd(scrollView)
        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        self.handleScrollEnd(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if self.swipeDirection == .Left {
            self.moveButtonsInHierarchy(false)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tailPosition = -scrollView.contentOffset.x + self.backgroundView!.frame.size.width
        let sizeDifference = scrollView.contentOffset.x - self.lastContentOffset
        
        let button_1 = self.viewWithTag(70)! as T2GCellButton
        button_1.resize(tailPosition, sizeDifference: sizeDifference)
        
        let button_2 = self.viewWithTag(71)! as T2GCellButton
        button_2.resize(tailPosition, sizeDifference: sizeDifference)
        
        let button_3 = self.viewWithTag(72)! as T2GCellButton
        button_3.resize(tailPosition, sizeDifference: sizeDifference)
        
        let button_4 = self.viewWithTag(73)! as T2GCellButton
        button_4.resize(tailPosition, sizeDifference: sizeDifference)

        
        if self.lastContentOffset < scrollView.contentOffset.x {
            self.swipeDirection = .Left
        } else {
            self.swipeDirection = .Right
        }
        
        self.lastContentOffset = scrollView.contentOffset.x
    }
}
