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
    func didSelectButton(tag: Int, index: Int)
    func didSelectMultipleChoiceButton(tag: Int, selected: Bool)
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
    
    var buttonCount: Int = 0
    
    private var swipeDirection: T2GCellSwipeDirection = .Left
    var lastContentOffset: CGFloat = 0
    
    //MARK: - Public API
    
    convenience init(header: String, detail: String, frame: CGRect, mode: T2GLayoutMode) {
        self.init(frame: frame)
        
        self.backgroundColor = UIColor.grayColor()
        
        self.scrollView = UIScrollView(frame: CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height + 2))
        self.scrollView!.backgroundColor = .clearColor()
        self.scrollView!.showsHorizontalScrollIndicator = false
        self.scrollView!.bounces = false
        self.scrollView!.delegate = self
    
        self.backgroundView = UIView(frame: CGRectMake(0, 0, self.frame.size.width + 2, self.frame.size.height + 2))
        self.backgroundView!.backgroundColor = .lightGrayColor()
        self.scrollView!.addSubview(self.backgroundView!)
        
        //let imageFrame = CGRectMake(0, 0, self.frame.height + 2, self.frame.height + 2)
        let imageFrame = CGRectMake(0, 0, 64 + 2, 64 + 2)
        self.imageView = UIView(frame: imageFrame)
        self.imageView!.backgroundColor = .blackColor()
        self.backgroundView!.addSubview(self.imageView!)
        
        let labelDimensions = self.framesForLabels(frame)
        
        self.headerLabel = UILabel(frame: labelDimensions.header)
        self.headerLabel!.backgroundColor = .blackColor()
        self.headerLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        self.headerLabel!.font = UIFont.boldSystemFontOfSize(13)
        self.headerLabel!.textColor = .whiteColor()
        self.headerLabel!.text = header
        self.backgroundView!.addSubview(self.headerLabel!)
        
        self.detailLabel = UILabel(frame: labelDimensions.detail)
        self.detailLabel!.backgroundColor = .blackColor()
        self.detailLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        self.detailLabel!.font = UIFont.systemFontOfSize(11)
        self.detailLabel!.textColor = .whiteColor()
        self.detailLabel!.text = detail
        self.backgroundView!.addSubview(self.detailLabel!)
        
        self.addSubview(self.scrollView!)
        
        if mode == .Collection {
            self.changeFrameParadigm(.Collection, frame: self.frame)
        }
    }
    
    func moveAllCrap(diff: CGFloat) {
        self.backgroundColor = .clearColor()
        
        for v in self.subviews {
            if let v2 = v as? UIView {
                let frame = CGRectMake(v.frame.origin.x + diff, v.frame.origin.y, v.frame.size.width, v.frame.size.height)
                v2.frame = frame
            }
        }
        
    }
    
    func toggleMultipleChoice(flag: Bool, selected: Bool, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        
        if flag {
            self.backgroundColor = .clearColor()
        }
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            let diff: CGFloat = flag ? 50.0 : -50.0
            
            let moveClosure = { () -> Void in
                for v in self.subviews {
                    if let v2 = v as? UIView {
                        let frame = CGRectMake(v.frame.origin.x + diff, v.frame.origin.y, v.frame.size.width, v.frame.size.height)
                        v2.frame = frame
                    }
                }
            }
            
            if flag {
                moveClosure()
                self.addMultipleChoiceButton(selected)
            } else {
                if let button = self.viewWithTag(100000 + self.tag) {
                    button.removeFromSuperview()
                }
                moveClosure()
            }
        }, completion: { (finished: Bool) -> Void in
            if !flag && self.viewWithTag(100000 + self.tag) == nil {
                self.backgroundColor = .grayColor()
            }
        })
    }
    
    func multipleChoiceButtonPressed(sender: T2GCheckboxButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.didSelectMultipleChoiceButton(self.tag, selected: sender.isSelected)
    }
    
    func addMultipleChoiceButton(selected: Bool) {
        let size = self.frame.size.height * 0.5
        let x = CGFloat(0.0) //(-self.frame.origin.x - size) / 2
        let y = (self.frame.size.height - size) / 2
        let frame = CGRectMake(x, y, size, size)
        
        let button = T2GCheckboxButton(frame: frame)
        button.isSelected = selected
        button.addTarget(self, action: "multipleChoiceButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = 100000 + self.tag
        button.alpha = 0.0
        self.addSubview(button)
        self.sendSubviewToBack(button)
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            button.alpha = 1.0
        }, completion: { (complete) -> Void in
            self.bringSubviewToFront(button)
        })
    }
    
    func changeFrameParadigm(mode: T2GLayoutMode, frame: CGRect) {
        if self.scrollView!.contentOffset.x != 0 {
            self.moveButtonsInHierarchy(shouldHide: true)
            self.scrollView!.contentOffset.x = 0
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
        
        if let button = self.viewWithTag(100000 + self.tag) {
            for v in self.subviews {
                if let v2 = v as? UIView {
                    if v2.tag != button.tag {
                        let frame = CGRectMake(v.frame.origin.x + 50.0, v.frame.origin.y, v.frame.size.width, v.frame.size.height)
                        v2.frame = frame
                    }
                }
            }
        }
    }
    
    func setupButtons(count: Int, mode: T2GLayoutMode) {
        self.buttonCount = count
        
        let coordinateData = self.coordinatesForButtons(count, mode: mode)
        let origins = coordinateData.origins
        
        for index in 0..<count {
            let point = origins[index]
            let view = T2GCellButton(frame: point)
            view.tag = 70 + index
            view.normalBackgroundColor = .blackColor()
            view.highlightedBackgroundColor = .lightGrayColor()
            view.setup()
            view.addTarget(self, action: "buttonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(view)
            self.sendSubviewToBack(view)
        }
        
        self.scrollView!.contentSize = CGSizeMake(self.frame.size.width * coordinateData.offsetMultiplier, self.frame.size.height)
    }
    
    func closeCell() {
        self.moveButtonsInHierarchy(shouldHide: true)
        self.swipeDirection = .Right
        self.handleScrollEnd(self.scrollView!)
    }
    
    //MARK: - Private API
    
    func coordinatesForButtons(count: Int, mode: T2GLayoutMode) -> (origins: [CGRect], offsetMultiplier: CGFloat) {
        let buttonSize: CGFloat = 16.0
        var coords: [CGRect] = []
        var multiplier: CGFloat = 1.0
        
        if mode == .Table {
            let margin = (self.frame.size.width - CGFloat(4 * buttonSize)) / 5.0
            let y = (self.frame.size.height - CGFloat(buttonSize)) / 2.0
            
            for index in 0..<count {
                let x = self.frame.size.width - (CGFloat(index + 1) * (CGFloat(buttonSize) + margin))
                multiplier = 1 + (1 - ((x - (margin * 0.75))/self.frame.size.width))
                coords.append(CGRectMake(x, y, buttonSize, buttonSize))
            }
        } else {
            let squareSize = CGFloat(self.frame.size.width)
            
            switch buttonCount {
            case 1:
                let x = (squareSize - buttonSize) / 2
                let y = x
                coords.append(CGRectMake(CGFloat(x),CGFloat(y),buttonSize,buttonSize))
                break
            case 2:
                let y = (squareSize - buttonSize) / 2
                let x1 = (squareSize / 2) - (buttonSize * 2)
                coords.append(CGRectMake(CGFloat(x1),CGFloat(y),buttonSize,buttonSize))
                
                let x2 = squareSize - x1 - buttonSize
                coords.append(CGRectMake(CGFloat(x2),CGFloat(y),buttonSize,buttonSize))
                
                break
            case 3:
                let x1 = (squareSize / 2) - (buttonSize * 2)
                let y1 = x1
                coords.append(CGRectMake(CGFloat(x1),CGFloat(y1),buttonSize,buttonSize))
                
                let x2 = squareSize - x1 - buttonSize
                let y2 = y1
                coords.append(CGRectMake(CGFloat(x2),CGFloat(y2),buttonSize,buttonSize))
                
                let x3 = (squareSize - buttonSize) / 2
                let y3 = squareSize - (buttonSize * 2)
                coords.append(CGRectMake(CGFloat(x3),CGFloat(y3),buttonSize,buttonSize))
                
                break
            case 4:
                let x1 = (squareSize / 2) - (buttonSize * 2)
                let y1 = x1
                coords.append(CGRectMake(CGFloat(x1),CGFloat(y1),buttonSize,buttonSize))
                
                let x2 = squareSize - x1 - buttonSize
                let y2 = y1
                coords.append(CGRectMake(CGFloat(x2),CGFloat(y2),buttonSize,buttonSize))
                
                let x3 = x1
                let y3 = squareSize - (buttonSize * 2)
                coords.append(CGRectMake(CGFloat(x3),CGFloat(y3),buttonSize,buttonSize))
                
                let x4 = x2
                let y4 = y3
                coords.append(CGRectMake(CGFloat(x4),CGFloat(y4),buttonSize,buttonSize))
                
                break
            default:
                break
            }
            
            multiplier = count == 0 ? 1.0 : 2.0
        }
        
        return (coords, multiplier)
    }
    
    func buttonSelected(sender: T2GCellButton) {
        self.delegate?.didSelectButton(self.tag - 333, index: sender.tag - 70)
    }
    
    func rearrangeButtons(mode: T2GLayoutMode) {
        let coordinateData = self.coordinatesForButtons(self.buttonCount, mode: mode)
        let origins = coordinateData.origins
        
        for index in 0..<self.buttonCount {
            if let view = self.viewWithTag(70 + index) as? T2GCellButton {
                let frame = origins[index]
                view.minOriginCoord = frame.origin
                view.frame = frame
            }
        }
        
        self.scrollView!.contentSize = CGSizeMake(self.frame.size.width * coordinateData.offsetMultiplier, self.frame.size.height)
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
    
    //MARK: - Scroll view delegate methods
    
    func handleScrollEnd(scrollView: UIScrollView) {
        let x = self.swipeDirection == .Right ? 0 : self.frame.size.width
        let frame = CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            scrollView.scrollRectToVisible(frame, animated: false)
        }, completion: { (complete) -> Void in
            if self.swipeDirection == .Right {
                self.delegate?.didCellClose(self.tag)
            } else {
                self.delegate?.didCellOpen(self.tag)
                self.moveButtonsInHierarchy(shouldHide: false)
            }
        })
    }
    
    func moveButtonsInHierarchy(#shouldHide: Bool) {
        for index in 0...3 {
            if let view = self.viewWithTag(70 + index) as? T2GCellButton {
                if shouldHide {
                    self.sendSubviewToBack(view)
                } else {
                    self.bringSubviewToFront(view)
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.delegate?.cellStartedSwiping(self.tag)
        
        self.moveButtonsInHierarchy(shouldHide: true)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            /*
            if scrollView.contentOffset.x != 0 {
                self.moveButtonsInHierarchy(false)
            }
            */
            self.handleScrollEnd(scrollView)
        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        self.handleScrollEnd(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if self.swipeDirection == .Left {
            self.moveButtonsInHierarchy(shouldHide: false)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tailPosition = -scrollView.contentOffset.x + self.backgroundView!.frame.size.width
        let sizeDifference = scrollView.contentOffset.x - self.lastContentOffset
        
        for index in 0..<self.buttonCount {
            if let button = self.viewWithTag(70 + index) as? T2GCellButton {
                button.resize(tailPosition, sizeDifference: sizeDifference)
            }
        }
        
        if self.lastContentOffset < scrollView.contentOffset.x {
            self.swipeDirection = .Left
        } else {
            self.swipeDirection = .Right
        }
        
        self.lastContentOffset = scrollView.contentOffset.x
    }
}
