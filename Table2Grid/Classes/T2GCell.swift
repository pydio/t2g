//
//  T2GCell.swift
//  Table2Grid Framework
//
//  Created by Michal Švácha on 20/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit
import Material

extension UIImage {
    /**
     Returns a new version of the image scaled to the specified size.
     - parameter size: The size to use when scaling the new image.
     - returns: A new image object.
     */
    public func af_imageScaledToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, af_isOpaque, 0.0)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}


extension UIImage {
    /// Returns whether the image contains an alpha component.
    public var af_containsAlphaComponent: Bool {
        let alphaInfo = CGImageGetAlphaInfo(CGImage)
        
        return (
            alphaInfo == .First ||
                alphaInfo == .Last ||
                alphaInfo == .PremultipliedFirst ||
                alphaInfo == .PremultipliedLast
        )
    }
    
    /// Returns whether the image is opaque.
    public var af_isOpaque: Bool { return !af_containsAlphaComponent }
}

/**
Protocol for handling the events of cell - selection, swiping the cell to open drawer or button press.
*/
protocol T2GCellDelegate {
    /**
    Gets called when swiping gesture began.
    
    :param: tag The tag of the swiped cell.
    */
    func cellStartedSwiping(tag: Int)
    
    /**
    Gets called when cell was selected.
    
    :param: tag The tag of the swiped cell.
    */
    func didSelectCell(tag: Int)
    
    
    /**
     Gets called when cell was checked from multiselection.
     
     :param: tag The tag of the swiped cell.
     */
    func didCheckCell(tag: Int)
    
    /**
     Gets called when cell was unchecked from multiselection.
     
     :param: tag The tag of the swiped cell.
     */
    func didUncheckCell(tag: Int)
    
    /**
    Gets called when cell was opened.
    
    :param: tag The tag of the swiped cell.
    */
    func didCellOpen(tag: Int)
    
    /**
    Gets called when cell was closed.
    
    :param: tag The tag of the swiped cell.
    */
    func didCellClose(tag: Int)
    
    /**
    Gets called when drawer button has been pressed.
    
    :param: tag The tag of the swiped cell.
    :param: index Index of the button - indexed from right to left starting with 0.
    */
    func didSelectButton(tag: Int, index: Int)
    
    
    /**
     Gets called when the cell has been long pressed.
     
     :param: tag The tag of the long pressed cell.
     */
    func didLongPressCell(tag: Int)
}

/**
Enum defining scrolling direction. Used for recognizing whether the cell should be closed or opened after the swiping gesture has ended half way through.
*/
private enum T2GCellSwipeDirection {
    case Right
    case Left
}

public enum ImageType {
    case Icon
    case Picture
}

/**
Base class for cells in T2GScrollView (can be overriden). Has all drag and drop functionality thanks to inheritance. Implements drawer feature - swipe to reveal buttons for more interaction.
*/
public class T2GCell: T2GDragAndDropView, UIScrollViewDelegate {
    var delegate: T2GCellDelegate?
    
    var highlighted: Bool = false {
        didSet {
            if let backgroundButton = self.backgroundView.viewWithTag(T2GViewTags.cellBackgroundButton) as? UIButton {
                backgroundButton.highlighted = self.highlighted
            }
        }
    }
    public var mode: T2GLayoutMode = .Collection

    public var header: String = ""
    public var detail: String = ""
    public var imageType: ImageType = .Icon
    public var isBookmarked: Bool = false
    public var isShared: Bool = false
    public var isSynced: Bool = false
    public var image: UIImage!
    var selected: Bool?
    
    // Common attribute
    public var scrollView: T2GCellDrawerScrollView = T2GCellDrawerScrollView()
    var backgroundView: MaterialPulseView = MaterialPulseView()
    var backgroundButton: FlatButton = FlatButton()
    
    
    var imageView: UIImageView = UIImageView()
    var headerLabel: MaterialLabel = MaterialLabel()
    var detailLabel: MaterialLabel = MaterialLabel()
    
    var infoView: MaterialView = MaterialView()
    var bookmarkImageView: UIImageView = UIImageView()
    var shareImageView: UIImageView = UIImageView()
    var syncImageView: UIImageView = UIImageView()
    public var moreButton: IconButton = IconButton()
    var selectionButton: IconButton = IconButton()

    // Collection attribute
    var whiteFooter: UIView = UIView()
    
    var buttonCount: Int = 0
    
    private var swipeDirection: T2GCellSwipeDirection = .Right
    private var lastContentOffset: CGFloat = 0
    
    /**
    Convenience initializer to initialize the cell with given parameters.
    
    - WARNING! To change the frame, do not use direct access to frame property. Use changeFrameParadigm instead (for rearranging all subviews).
    
    :param: header Main text line.
    :param: detail Detail text line.
    :param: frame Frame for the cell.
    :param: mode Which mode the cell is in (T2GLayoutMode).
    */
    public convenience init(header: String, detail: String,  icon: String?, image: NSData? = nil, isBookmarked: Bool = false, isShared: Bool = false, isSynced: Bool = false, frame: CGRect, mode: T2GLayoutMode) {
        self.init(frame: frame)
        
        self.header = header
        self.detail = detail
        self.isBookmarked = isBookmarked
        self.isShared = isShared
        self.isSynced = isSynced
        if image?.length != 0 {
            self.imageType = .Picture
            self.image = UIImage(data: image!)
        } else {
            self.imageType = .Icon
            self.image = UIImage(named: icon!)
        }
        self.mode = mode
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(T2GCell.cellIsLongPressed))
        longPressRecognizer.minimumPressDuration = 1.5
        self.addGestureRecognizer(longPressRecognizer)
        self.renderCell()
    }
    
    public func renderCell() {
        removeConstraints(constraints)
        scrollView.removeConstraints(scrollView.constraints)
        backgroundView.removeConstraints(backgroundView.constraints)
        imageView.removeConstraints(imageView.constraints)
        infoView.removeConstraints(infoView.constraints)
        whiteFooter.removeConstraints(whiteFooter.constraints)
        
        bookmarkImageView.hidden = !isBookmarked
        shareImageView.hidden = !isShared
        syncImageView.hidden = !isSynced

        prepareScrollView()
        prepareBackgroundView()
        prepareImageView()
        prepareInfoView()
        prepareBackgroundButton()

        
        if mode == .Table {
            backgroundColor = T2GStyle.Node.Table.backgroundColor
            detailLabel.hidden = false
            whiteFooter.hidden = true
            
            prepareHeaderLabel()
            prepareDetailLabel()
            prepareMoreButton()
            prepareSelectionButton()
        } else if mode == .Collection {
            backgroundColor = T2GStyle.Node.Collection.backgroundColor
            detailLabel.hidden = true
            whiteFooter.hidden = false
            
            prepareWhiteFooter()
            prepareHeaderLabel()
            prepareMoreButton()
            prepareSelectionButton()
        }
        
        if scrollView.contentOffset.x != 0 {
            moveButtonsInHierarchy(true)
            scrollView.contentOffset.x = 0
        }
        
        backgroundView.bringSubviewToFront(backgroundButton)
        if mode == .Table {
            backgroundView.bringSubviewToFront(moreButton)
            bringSubviewToFront(backgroundView)
        }
        rearrangeButtons(mode)
    }
    
    func prepareScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = T2GStyle.Node.nodeScrollViewBackgroundColor
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        addSubview(scrollView)
        
        if mode == .Table {
            scrollView.scrollEnabled = selected == nil ? true : false
            addConstraints([ // SCROLLVIEW
                NSLayoutConstraint(item: scrollView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0),
                ])
        } else {
            scrollView.scrollEnabled = false
            addConstraints([ // SCROLLVIEW
                NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: frame.height / 5 * 4),
                NSLayoutConstraint(item: scrollView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
                ])
        }
    }
    
    func prepareWhiteFooter() {
        whiteFooter.translatesAutoresizingMaskIntoConstraints = false
        whiteFooter.backgroundColor = T2GStyle.Node.Collection.whiteFooterBackgroundColor
        prepareMoreButton()
        prepareSelectionButton()
        prepareHeaderLabel()
        addSubview(whiteFooter)
        addConstraints([ // WHITE FOOTER
            NSLayoutConstraint(item: whiteFooter, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: whiteFooter, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: whiteFooter, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: frame.height / 5),
            NSLayoutConstraint(item: whiteFooter, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
            ])
    }
    
    func prepareBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = MaterialColor.white
        backgroundView.depth = MaterialDepth.Depth5
        scrollView.addSubview(backgroundView)
        scrollView.addConstraints([ // BACKGROUND VIEW
            NSLayoutConstraint(item: backgroundView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundView, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundView, attribute: .CenterX, relatedBy: .Equal, toItem: scrollView, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundView, attribute: .CenterY, relatedBy: .Equal, toItem: scrollView, attribute: .CenterY, multiplier: 1, constant: 0),
            ])
    }
    
    
    func prepareBackgroundButton() {
        backgroundButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundButton.tag = T2GViewTags.cellBackgroundButton
        backgroundButton.backgroundColor = MaterialColor.clear
        backgroundButton.addTarget(self, action: #selector(T2GCell.backgroundViewButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        backgroundView.addSubview(backgroundButton)
        backgroundView.addConstraints([ // CELL BUTTON
            NSLayoutConstraint(item: backgroundButton, attribute: .Width, relatedBy: .Equal, toItem: backgroundView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundButton, attribute: .Height, relatedBy: .Equal, toItem: backgroundView, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundButton, attribute: .CenterX, relatedBy: .Equal, toItem: backgroundView, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundButton, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundView, attribute: .CenterY, multiplier: 1, constant: 0),
            ])
    }
    
    func prepareImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if imageType == .Icon {
            imageView.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate).af_imageScaledToSize(CGSize(width: 30, height: 30)).tintWithColor(MaterialColor.grey.base)
            imageView.backgroundColor = T2GStyle.Node.nodeIconViewBackgroundColor
            imageView.contentMode = .Center
        } else {
            imageView.image = image
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
        }
        backgroundView.addSubview(imageView)
        backgroundView.addConstraints([ // ICON VIEW
            NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundView, attribute: .CenterY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: backgroundView, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .Width , relatedBy: .Equal, toItem: backgroundView, attribute: .Height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .Height , relatedBy: .Equal, toItem: backgroundView, attribute: .Height, multiplier: 1, constant: 0),
            ])
    }
    
    
    func prepareInfoView() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = MaterialColor.clear
        prepareAnnotation(bookmarkImageView, imageName: "bookmark", color: UIColor(named: .PYDBlue))
        prepareAnnotation(shareImageView, imageName: "share-variant", color: UIColor(named: .PYDMarine))
        prepareAnnotation(syncImageView, imageName: "sync", color: UIColor(named: .PYDOrange))
        imageView.addSubview(infoView)
        imageView.addConstraints([ // INFOVIEW
            NSLayoutConstraint(item: infoView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: infoView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: infoView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: infoView, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0),
            ])
        infoView.addConstraints([ // BOOKMARK IMAGE VIEW
            NSLayoutConstraint(item: bookmarkImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: bookmarkImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: bookmarkImageView, attribute: .CenterY, relatedBy: .Equal, toItem: infoView, attribute: .CenterY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bookmarkImageView, attribute: .Trailing, relatedBy: .Equal, toItem: infoView, attribute: .Trailing, multiplier: 1, constant: -5),
            ])
        infoView.addConstraints([ // SHARE IMAGE VIEW
            NSLayoutConstraint(item: shareImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: shareImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: shareImageView, attribute: .CenterY, relatedBy: .Equal, toItem: bookmarkImageView, attribute: .CenterY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: shareImageView, attribute: .Trailing, relatedBy: .Equal, toItem: bookmarkImageView, attribute: .Leading, multiplier: 1, constant: -5),
            ])
        infoView.addConstraints([ // SYNC IMAGE VIEW
            NSLayoutConstraint(item: syncImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: syncImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: syncImageView, attribute: .CenterY, relatedBy: .Equal, toItem: shareImageView, attribute: .CenterY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: syncImageView, attribute: .Trailing, relatedBy: .Equal, toItem: shareImageView, attribute: .Leading, multiplier: 1, constant: -5),
            ])
    }
    
    func prepareAnnotation(annotation: UIImageView, imageName: String, color: UIColor) {
        annotation.translatesAutoresizingMaskIntoConstraints = false
        annotation.image = UIImage(named: imageName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate).af_imageScaledToSize(CGSize(width: 10, height: 10)).tintWithColor(MaterialColor.white)
        annotation.backgroundColor = color
        annotation.contentMode = .Center
        annotation.layer.cornerRadius = 7.5
        infoView.addSubview(annotation)
    }
    
    func prepareMoreButton() {
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.pulseColor = MaterialColor.grey.base
        moreButton.tintColor = MaterialColor.grey.lighten1
        moreButton.setImage(MaterialIcon.cm.moreVertical, forState: .Normal)
        moreButton.setImage(MaterialIcon.cm.moreVertical, forState: .Highlighted)
        moreButton.addTarget(self, action: #selector(T2GCell.moreButtonImagePressed(_:)), forControlEvents: .TouchUpInside)
        if mode == .Table {
            backgroundView.addSubview(moreButton)
            backgroundView.addConstraints([ // MORE BUTTON
                NSLayoutConstraint(item: moreButton, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundView, attribute: .CenterY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: moreButton, attribute: .Trailing, relatedBy: .Equal, toItem: backgroundView, attribute: .Trailing, multiplier: 1, constant: 0)
                ])
        } else {
            whiteFooter.addSubview(moreButton)
            whiteFooter.addConstraints([ // MORE BUTTON
                NSLayoutConstraint(item: moreButton, attribute: .CenterY, relatedBy: .Equal, toItem: whiteFooter, attribute: .CenterY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: moreButton, attribute: .Trailing, relatedBy: .Equal, toItem: whiteFooter, attribute: .Trailing, multiplier: 1, constant: 0)
                ])
        }
    }
    
    func prepareSelectionButton() {
        let image = UIImage(named: "checkbox-marked-circle")?.imageWithRenderingMode(.AlwaysTemplate)
        if selected == nil {
            selectionButton.alpha = 0
            selectionButton.hidden = true
            selectionButton.tintColor = MaterialColor.grey.base
        } else if selected == true {
            selectionButton.tintColor = MaterialColor.blue.base
        } else if selected == false {
            selectionButton.tintColor = MaterialColor.grey.base
        }
        selectionButton.pulseColor = MaterialColor.grey.base
        selectionButton.setImage(image, forState: .Normal)
        selectionButton.setImage(image, forState: .Highlighted)
        selectionButton.addTarget(self, action: #selector(T2GCell.selectionButtonPressed(_:)), forControlEvents: .TouchUpInside)
        selectionButton.translatesAutoresizingMaskIntoConstraints = false
        if mode == .Table {
            backgroundView.addSubview(selectionButton)
            backgroundView.addConstraints([ // SELECTION BUTTON
                NSLayoutConstraint(item: selectionButton, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundView, attribute: .CenterY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: selectionButton, attribute: .Trailing, relatedBy: .Equal, toItem: backgroundView, attribute: .Trailing, multiplier: 1, constant: 0)
                ])
        } else {
            whiteFooter.addSubview(selectionButton)
            whiteFooter.addConstraints([ // SELECTION BUTTON
                NSLayoutConstraint(item: selectionButton, attribute: .CenterY, relatedBy: .Equal, toItem: whiteFooter, attribute: .CenterY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: selectionButton, attribute: .Trailing, relatedBy: .Equal, toItem: whiteFooter, attribute: .Trailing, multiplier: 1, constant: 0)
                ])
        }
    }
    
    func prepareHeaderLabel() {
        headerLabel.backgroundColor = .clearColor()
        headerLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        headerLabel.font = T2GStyle.Node.nodeTitleFont
        headerLabel.textColor = T2GStyle.Node.nodeTitleColor
        headerLabel.text = header
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        if mode == .Table {
            backgroundView.addSubview(headerLabel)
            backgroundView.addConstraints([ // HEADER LABEL
                NSLayoutConstraint(item: headerLabel, attribute: .Leading, relatedBy: .Equal, toItem: imageView, attribute: .Trailing, multiplier: 1, constant: 20),
                NSLayoutConstraint(item: headerLabel, attribute: .Trailing, relatedBy: .Equal, toItem: backgroundView, attribute: .Trailing, multiplier: 1, constant: -42),
                NSLayoutConstraint(item: headerLabel, attribute: .Top, relatedBy: .Equal, toItem: backgroundView, attribute: .Top, multiplier: 1, constant: 20),
                ])
        } else {
            whiteFooter.addSubview(headerLabel)
            whiteFooter.addConstraints([ // HEADER LABEL
                NSLayoutConstraint(item: headerLabel, attribute: .Leading, relatedBy: .Equal, toItem: whiteFooter, attribute: .Leading, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: headerLabel, attribute: .Trailing, relatedBy: .Equal, toItem: whiteFooter, attribute: .Trailing, multiplier: 1, constant: -42),
                NSLayoutConstraint(item: headerLabel, attribute: .CenterY, relatedBy: .Equal, toItem: whiteFooter, attribute: .CenterY, multiplier: 1, constant: 0),
                ])
        }
    }
    
    func prepareDetailLabel() {
        detailLabel.backgroundColor = .clearColor()
        detailLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        detailLabel.font = T2GStyle.Node.nodeDescriptionFont
        detailLabel.textColor = T2GStyle.Node.nodeDescriptionColor
        detailLabel.text = detail
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(detailLabel)
        backgroundView.addConstraints([ // DETAIL LABEL
            NSLayoutConstraint(item: detailLabel, attribute: .Leading, relatedBy: .Equal, toItem: imageView, attribute: .Trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: detailLabel, attribute: .Trailing, relatedBy: .Equal, toItem: backgroundView, attribute: .Trailing, multiplier: 1, constant: -42),
            NSLayoutConstraint(item: detailLabel, attribute: .Top, relatedBy: .Equal, toItem: headerLabel, attribute: .Bottom, multiplier: 1, constant: 5),
            ])
    }
    
    public func cellSetSelected(selected: Bool) {
        self.selected = selected
        if self.selected! {
            selectionButton.tintColor = MaterialColor.blue.base
            delegate?.didCheckCell(tag)
        } else {
            selectionButton.tintColor = MaterialColor.grey.base
            delegate?.didUncheckCell(tag)
        }
    }
    
    /**
    Gets called when the cell has been pressed (standard tap gesture). Forwards the action to the delegate.
    
    :param: sender The button that initiated the action (that is a subview of backgroundView property).
    */
    func backgroundViewButtonPressed(sender: UIButton) {
        if selected == nil {
            delegate?.didSelectCell(tag)
        } else {
            cellSetSelected(!selected!)
        }
    }
    
    /**
    Changes frame of the cell. Should be used for any resizing or transforming of the cell. Handles resizing of all the subviews.
    
    :param: mode T2GLayoutMode in which the T2GScrollView is.
    :param: frame Frame to which the cell should resize.
    */
    func changeFrameParadigm(mode: T2GLayoutMode, frame: CGRect) {
        self.frame = frame
        self.mode = mode
        renderCell()
    }
    
    /**
    Sets up buttons in drawer.
    
    :param: array of custom actions
    :param: mode T2GLayoutMode in which the T2GScrollView is.
    */
    public func setupActions(actions: [(title: String, image: UIImage, handler: Void->Void)], mode: T2GLayoutMode) {
        let a: Void->Void
        let b: ()->()
        
        let count = actions.count
        buttonCount = count
        
        let coordinateData = self.coordinatesForButtons(count, mode: mode)
        let origins = coordinateData.frames
        
        for index in 0..<count {
            let point = origins[index]
            let view = T2GCellDrawerButton(frame: point)
            view.tag = T2GViewTags.cellDrawerButtonConstant + index
            
            var img = actions[index].image
            img = img.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            view.tintColor = T2GStyle.Node.nodeImageViewTintColor
            view.backgroundColor = .clearColor()
            view.setBackgroundImage(img, forState: UIControlState.Normal)
            view.setBackgroundImage(img, forState: UIControlState.Selected)
            view.setBackgroundImage(img, forState: UIControlState.Highlighted)
            view.handler = actions[index].handler
            view.addTarget(self, action: #selector(cellBackgroundButtonPressed(_:)), forControlEvents: .TouchUpInside)
            addSubview(view)
            sendSubviewToBack(view)
        }
        
        self.scrollView.contentSize = CGSizeMake(frame.size.width * 2 - frame.size.height, frame.size.height)
    }
    
    /**
    Closes the drawer if it's opened.
    */
    func closeCell() {
        moveButtonsInHierarchy(true)
        swipeDirection = .Right
        handleScrollEnd(scrollView)
    }
    
    /**
     Gets called when T2GCellDrawerButton has been pressed. Execute the handler and close the cell
     
     :param: sender T2GCellDrawerButton that has been pressed.
     */
    func cellBackgroundButtonPressed(sender: T2GCellDrawerButton) {
        if let handler = sender.handler {
            handler()
            closeCell()
        }
    }
    

    //MARK: - Multiple choice toggle
    
    /**
    Transforms the view to edit mode - adds checkbox for multiple selection.
    
    :param: flag Flag indicating whether it is TO (true) or FROM (false).
    :param: mode T2GLayoutMode in which the T2GScrollView is.
    :param: selected Flag indicating if created checkbox should be selected.
    :param: animated Flag indicating if the whole transformation process should be animated (desired for initial transformation, but maybe not so much while scrolling).
    */
    func toggleMultipleChoice(flag: Bool, mode: T2GLayoutMode, selected: Bool, animated: Bool) {
        updateLayoutForEdit(flag, mode: mode, selected: selected, animated: animated)
    }
    
    func updateLayoutForEdit(flag: Bool, mode: T2GLayoutMode, selected: Bool, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        
        if flag {
            backgroundColor = .clearColor()
        }
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.moreButton.alpha = flag ? 0 : 1
            }, completion:  {(_) -> Void in
                self.moreButton.hidden = flag
                self.selectionButton.hidden = !flag
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.selectionButton.alpha = !flag ? 0 : 1
                    }, completion:  {(_) -> Void in
                })
        })
        
        if flag {
            if self.selected == nil {
                self.selected = false
                cellSetSelected(false)
            }
        } else {
            self.selected = nil
        }
    }
    
    //MARK: - Helper methods
    
    /**
    Calculates coordinates for buttons in the drawer.
    
    :param: count Number of buttons.
    :param: mode T2GLayoutMode in which the T2GScrollView is.
    :returns: Tuple (frames: [CGRect], offsetMultiplier: CGFloat) - array of frames for the buttons and multipler for how wide the content view of the scrollView needs to be to open as far as it is necessary.
    */
    func coordinatesForButtons(count: Int, mode: T2GLayoutMode) -> (frames: [CGRect], offsetMultiplier: CGFloat) {
        let buttonSize: CGFloat = 12.0
        var coords: [CGRect] = []
        var multiplier: CGFloat = 1.0
        
        if mode == .Table {
            let m = (frame.size.width - frame.size.height) / 4
            let margin = frame.height + m/2 - buttonSize / 2
            let y = (frame.size.height - CGFloat(buttonSize)) / 2.0
            
            for index in 0..<count {
                let x = margin + (m * CGFloat(index))
                coords.append(CGRectMake(x, y, buttonSize, buttonSize))
                multiplier = 1 + (1 - frame.height/frame.width)
            }
        } else {
            let padding = frame.height / 5 * 4 / 4
            let imgPadding = buttonSize / 2
            
            switch buttonCount {
            case 1...4:
                coords.append(CGRectMake(padding + imgPadding, padding + imgPadding, buttonSize, buttonSize))
                fallthrough
            case 2...4:
                coords.append(CGRectMake(padding * 3 - imgPadding, padding + imgPadding, buttonSize, buttonSize))
                fallthrough
            case 3,4:
                coords.append(CGRectMake(padding + imgPadding, padding * 3 - imgPadding, buttonSize, buttonSize))
                fallthrough
            case 4:
                coords.append(CGRectMake(padding * 3 - imgPadding, padding * 3 - imgPadding, buttonSize, buttonSize))
                fallthrough
            default: break
            }
            multiplier = count == 0 ? 1.0 : 2.0
        }
        return (coords, multiplier)
    }
    
    /**
    Helper method to rearrange buttons when changeFrameParadigm method gets called.
    
    :param: mode T2GLayoutMode in which the T2GScrollView is.
    */
    func rearrangeButtons(mode: T2GLayoutMode) {
        let coordinateData = coordinatesForButtons(buttonCount, mode: mode)
        let origins = coordinateData.frames
        
        for index in 0..<buttonCount {
            if let view = viewWithTag(T2GViewTags.cellDrawerButtonConstant + index) as? T2GCellDrawerButton {
                let frame = origins[index]
                view.minOriginCoord = frame.origin
                view.frame = frame
            }
        }
        
        self.scrollView.contentSize = CGSizeMake(frame.size.width * coordinateData.offsetMultiplier, frame.size.height)
    }
    
    func moreButtonImagePressed(sender: IconButton) {
//        self.delegate?.cellStartedSwiping(self.tag)
//        self.moveButtonsInHierarchy(true)
        if self.swipeDirection == .Left {
            closeCell()
        } else if swipeDirection == .Right {
            swipeDirection = .Left
            handleScrollEnd(scrollView)
        }
    }
    
    func selectionButtonPressed(sender: IconButton) {
    
    }
    
    //MARK: - Scroll view delegate methods
    
    /**
    Helper method that handles the end of scroll motion - closes or opens the drawer.
    
    :param: scrollView The UIScrollView where scrolling motion happened.
    */
    func handleScrollEnd(scrollView: UIScrollView) {
        var x: CGFloat = 0
        if mode == .Table {
            x = swipeDirection == .Right ? 0 : frame.size.width - imageView.frame.size.width
        } else {
            x = swipeDirection == .Right ? 0 : frame.size.width
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        }, completion: { (_) -> Void in
            if self.swipeDirection == .Right {
                self.delegate?.didCellClose(self.tag)
            } else {
                self.delegate?.didCellOpen(self.tag)
                self.moveButtonsInHierarchy(false)
            }
        })
    }
    
    /**
    Helper method that sends drawer buttons to front/back in the view hierarchy while the scrollView gets scrolled.
    
    :param: shouldHide Flag determining whether the scrollView is getting closed or opened.
    */
    func moveButtonsInHierarchy(shouldHide: Bool) {
        for index in 0...3 {
            if let view = viewWithTag(T2GViewTags.cellDrawerButtonConstant + index) as? T2GCellDrawerButton {
                if shouldHide {
                    sendSubviewToBack(view)
                } else {
                    bringSubviewToFront(view)
                }
            }
        }
    }
    
    /**
    Default Cocoa API - Tells the delegate when the scroll view is about to start scrolling the content.
    
    Informs the delegate that swiping motion began and moves buttons in hierarchy so they can be tapped.
    
    :param: scrollView The scroll-view object that is about to scroll the content view.
    */
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.cellStartedSwiping(tag)
        moveButtonsInHierarchy(true)
    }
    
    /**
    Default Cocoa API - Tells the delegate when dragging ended in the scroll view.
    
    If dragging stopped by user (= no deceleration), handleScrollEnd gets called (open/close so it doesn't stay half-way open).
    
    :param: scrollView The scroll-view object that finished scrolling the content view.
    :param: decelerate True if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
    */
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd(scrollView)
        }
    }
    
    /**
    Default Cocoa API - Tells the delegate that the scroll view is starting to decelerate the scrolling movement.
    
    Method handleScrollEnd gets called (open/close so it doesn't stay half-way open).
    
    :param: scrollView The scroll-view object that is decelerating the scrolling of the content view.
    */
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        handleScrollEnd(scrollView)
    }
    
    /**
    Default Cocoa API - Tells the delegate when a scrolling animation in the scroll view concludes.
    
    Shows buttons if the drawer was opened.
    
    :param: scrollView The scroll-view object that is performing the scrolling animation.
    */
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if swipeDirection == .Left {
            moveButtonsInHierarchy(false)
        }
    }
    
    /**
    Default Cocoa API - Tells the delegate when the user scrolls the content view within the receiver.
    
    Animates buttons while scrollView gets scrolled (bigger while opening, smaller while closing). Also determines direction of the swipe.
    
    :param: scrollView The scroll-view object in which the scrolling occurred.
    */
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let tailPosition = -scrollView.contentOffset.x + backgroundView.frame.size.width
        let sizeDifference = scrollView.contentOffset.x - lastContentOffset
        
        for index in 0..<buttonCount {
            if let button = viewWithTag(T2GViewTags.cellDrawerButtonConstant + index) as? T2GCellDrawerButton {
                button.resize(tailPosition, sizeDifference: sizeDifference)
            }
        }
        
        if lastContentOffset < scrollView.contentOffset.x && scrollView.contentOffset.x > scrollView.frame.width / 4 {
            swipeDirection = .Left
        } else {
            swipeDirection = .Right
        }
        
        lastContentOffset = scrollView.contentOffset.x
    }
    
    
    func cellIsLongPressed() {
        delegate?.didLongPressCell(tag)
    }
    
    //MARK: - T2GDragAndDropOwner delegate methods
    
    /**
    Adds long press gesture to the scrollView of the cell. It has to be done this way, because swiping is superior to long press. By this, the swiping gesture is always performed when user wants it to be performed.
    
    :param: recognizer Long press gesture created when draggable flag is set to true.
    */
    func addGestureRecognizerToView(recognizer: UILongPressGestureRecognizer) {
        scrollView.addGestureRecognizer(longPressGestureRecognizer!)
    }
}
