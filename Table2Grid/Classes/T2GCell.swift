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
    public func af_imageScaledToSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, af_isOpaque, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}


extension UIImage {
    /// Returns whether the image contains an alpha component.
    public var af_containsAlphaComponent: Bool {
        let alphaInfo = cgImage?.alphaInfo
        
        return (
            alphaInfo == .first ||
                alphaInfo == .last ||
                alphaInfo == .premultipliedFirst ||
                alphaInfo == .premultipliedLast
        )
    }
    
    /// Returns whether the image is opaque.
    public var af_isOpaque: Bool { return !af_containsAlphaComponent }
}

/**
Protocol for handling the events of cell - selection, swiping the cell to open drawer or button press.
*/
protocol T2GCellDelegate: class {
    /**
    Gets called when swiping gesture began.
    
    :param: tag The tag of the swiped cell.
    */
    func cellStartedSwiping(_ tag: Int)
    
    /**
    Gets called when cell was selected.
    
    :param: tag The tag of the swiped cell.
    */
    func didSelectCell(_ tag: Int)
    
    
    /**
     Gets called when cell was checked from multiselection.
     
     :param: tag The tag of the swiped cell.
     */
    func didCheckCell(_ tag: Int)
    
    /**
     Gets called when cell was unchecked from multiselection.
     
     :param: tag The tag of the swiped cell.
     */
    func didUncheckCell(_ tag: Int)
    
    /**
    Gets called when cell was opened.
    
    :param: tag The tag of the swiped cell.
    */
    func didCellOpen(_ tag: Int)
    
    /**
    Gets called when cell was closed.
    
    :param: tag The tag of the swiped cell.
    */
    func didCellClose(_ tag: Int)
    
    /**
    Gets called when drawer button has been pressed.
    
    :param: tag The tag of the swiped cell.
    :param: index Index of the button - indexed from right to left starting with 0.
    */
    func didSelectButton(_ tag: Int, index: Int)
    
    
    /**
     Gets called when the cell has been long pressed.
     
     :param: tag The tag of the long pressed cell.
     */
    func didLongPressCell(_ tag: Int)
}

/**
Enum defining scrolling direction. Used for recognizing whether the cell should be closed or opened after the swiping gesture has ended half way through.
*/
private enum T2GCellSwipeDirection {
    case right
    case left
}

public enum ImageType {
    case icon
    case picture
}

/**
Base class for cells in T2GScrollView (can be overriden). Has all drag and drop functionality thanks to inheritance. Implements drawer feature - swipe to reveal buttons for more interaction.
*/
open class T2GCell: T2GDragAndDropView, UIScrollViewDelegate {
    weak var delegate: T2GCellDelegate?
    
    var highlighted: Bool = false {
        didSet {
            if let backgroundButton = self.backgroundView.viewWithTag(T2GViewTags.cellBackgroundButton) as? UIButton {
                backgroundButton.isHighlighted = self.highlighted
            }
        }
    }
    open var mode: T2GLayoutMode = .collection

    open var header: String = ""
    open var detail: String = ""
    open var imageType: ImageType = .icon
    open var isBookmarked: Bool = false
    open var isShared: Bool = false
    open var isSynced: Bool = false
    open var image: UIImage!
    var selected: Bool?
    
    // Common attribute
    open var scrollView: T2GCellDrawerScrollView = T2GCellDrawerScrollView()
    var backgroundView: PulseView = PulseView()
    var backgroundButton: FlatButton = FlatButton()
    
    
    var imageView: UIImageView = UIImageView()
    var headerLabel: UILabel = UILabel()
    var detailLabel: UILabel = UILabel()
    
    var infoView: View = View()
    var bookmarkImageView: UIImageView = UIImageView()
    var shareImageView: UIImageView = UIImageView()
    var syncImageView: UIImageView = UIImageView()
    open var moreButton: IconButton = IconButton()
    var selectionButton: IconButton = IconButton()

    // Collection attribute
    var whiteFooter: UIView = UIView()
    
    var buttonCount: Int = 0
    
    fileprivate var swipeDirection: T2GCellSwipeDirection = .right
    fileprivate var lastContentOffset: CGFloat = 0
    
    /**
    Convenience initializer to initialize the cell with given parameters.
    
    - WARNING! To change the frame, do not use direct access to frame property. Use changeFrameParadigm instead (for rearranging all subviews).
    
    :param: header Main text line.
    :param: detail Detail text line.
    :param: frame Frame for the cell.
    :param: mode Which mode the cell is in (T2GLayoutMode).
    */
    public convenience init(header: String, detail: String,  icon: String?, image: Data? = nil, isBookmarked: Bool = false, isShared: Bool = false, isSynced: Bool = false, frame: CGRect, mode: T2GLayoutMode) {
        self.init(frame: frame)
        
        self.header = header
        self.detail = detail
        self.isBookmarked = isBookmarked
        self.isShared = isShared
        self.isSynced = isSynced
        if image?.count != 0 {
            self.imageType = .picture
            self.image = UIImage(data: image!)
        } else {
            self.imageType = .icon
            self.image = UIImage(named: icon!)
            if self.image == nil {
                self.image = UIImage(named: "file")?.withRenderingMode(.alwaysTemplate)
            }
        }
        self.mode = mode
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(T2GCell.cellIsLongPressed))
        longPressRecognizer.minimumPressDuration = 1.5
        self.addGestureRecognizer(longPressRecognizer)
        self.renderCell()
    }
    
    open func renderCell() {
        removeConstraints(constraints)
        scrollView.removeConstraints(scrollView.constraints)
        backgroundView.removeConstraints(backgroundView.constraints)
        imageView.removeConstraints(imageView.constraints)
        infoView.removeConstraints(infoView.constraints)
        whiteFooter.removeConstraints(whiteFooter.constraints)
        
        bookmarkImageView.isHidden = !isBookmarked
        shareImageView.isHidden = !isShared
        syncImageView.isHidden = !isSynced

        prepareScrollView()
        prepareBackgroundView()
        prepareImageView()
        prepareInfoView()
        prepareBackgroundButton()

        
        if mode == .table {
            backgroundColor = T2GStyle.Node.Table.backgroundColor
            detailLabel.isHidden = false
            whiteFooter.isHidden = true
            
            prepareHeaderLabel()
            prepareDetailLabel()
            prepareMoreButton()
            prepareSelectionButton()
        } else if mode == .collection {
            backgroundColor = T2GStyle.Node.Collection.backgroundColor
            detailLabel.isHidden = true
            whiteFooter.isHidden = false
            
            prepareWhiteFooter()
            prepareHeaderLabel()
            prepareMoreButton()
            prepareSelectionButton()
        }
        
        if scrollView.contentOffset.x != 0 {
            moveButtonsInHierarchy(true)
            scrollView.contentOffset.x = 0
        }
        
        backgroundView.bringSubview(toFront: backgroundButton)
        if mode == .table {
            backgroundView.bringSubview(toFront: moreButton)
            bringSubview(toFront: backgroundView)
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
        
        if mode == .table {
            scrollView.isScrollEnabled = selected == nil ? true : false
            addConstraints([ // SCROLLVIEW
                NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
                ])
        } else {
            scrollView.isScrollEnabled = false
            addConstraints([ // SCROLLVIEW
                NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: frame.height / 5 * 4),
                NSLayoutConstraint(item: scrollView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
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
            NSLayoutConstraint(item: whiteFooter, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: whiteFooter, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: whiteFooter, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: frame.height / 5),
            NSLayoutConstraint(item: whiteFooter, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            ])
    }
    
    func prepareBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = Color.white
        backgroundView.depthPreset = .depth5
        scrollView.addSubview(backgroundView)
        scrollView.addConstraints([ // BACKGROUND VIEW
            NSLayoutConstraint(item: backgroundView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0),
            ])
    }
    
    
    func prepareBackgroundButton() {
        backgroundButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundButton.tag = T2GViewTags.cellBackgroundButton
        backgroundButton.backgroundColor = Color.clear
        backgroundButton.addTarget(self, action: #selector(T2GCell.backgroundViewButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        backgroundView.addSubview(backgroundButton)
        backgroundView.addConstraints([ // CELL BUTTON
            NSLayoutConstraint(item: backgroundButton, attribute: .width, relatedBy: .equal, toItem: backgroundView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundButton, attribute: .height, relatedBy: .equal, toItem: backgroundView, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundButton, attribute: .centerX, relatedBy: .equal, toItem: backgroundView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundButton, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0),
            ])
    }
    
    func prepareImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let img = image {
            if imageType == .icon {
                imageView.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate).af_imageScaledToSize(CGSize(width: 30, height: 30)).tint(with: Color.grey.base)
                imageView.backgroundColor = T2GStyle.Node.nodeIconViewBackgroundColor
                imageView.contentMode = .center
            } else {
                imageView.image = image
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
            }        
        }
        backgroundView.addSubview(imageView)
        backgroundView.addConstraints([ // ICON VIEW
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: backgroundView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .width , relatedBy: .equal, toItem: backgroundView, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .height , relatedBy: .equal, toItem: backgroundView, attribute: .height, multiplier: 1, constant: 0),
            ])
    }
    
    
    func prepareInfoView() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = Color.clear
        if isSynced {
            prepareAnnotation(syncImageView, imageName: "sync", color: UIColor(named: .pydOrange))
        }
        if isShared {
            prepareAnnotation(shareImageView, imageName: "share-variant", color: UIColor(named: .pydMarine))
        }
        if isBookmarked {
            prepareAnnotation(bookmarkImageView, imageName: "bookmark", color: UIColor(named: .pydBlue))
        }
        
        var oldView: UIView = UIView()
        for (i, v) in infoView.subviews.enumerated() {

            if i == 0 {
                infoView.addConstraints([ // First subview
                    NSLayoutConstraint(item: v, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
                    NSLayoutConstraint(item: v, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
                    NSLayoutConstraint(item: v, attribute: .centerY, relatedBy: .equal, toItem: infoView, attribute: .centerY, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: infoView, attribute: .trailing, multiplier: 1, constant: -5),
                    ])
            } else {
                infoView.addConstraints([ // other subviews
                    NSLayoutConstraint(item: v, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
                    NSLayoutConstraint(item: v, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
                    NSLayoutConstraint(item: v, attribute: .centerY, relatedBy: .equal, toItem: oldView, attribute: .centerY, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: oldView, attribute: .leading, multiplier: 1, constant: -5),
                    ])
            }
            oldView = v
        }
        imageView.addSubview(infoView)
        imageView.addConstraints([ // INFOVIEW
            NSLayoutConstraint(item: infoView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: infoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 22),
            NSLayoutConstraint(item: infoView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: infoView, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1, constant: 0),
            ])
    }
    
    func prepareAnnotation(_ annotation: UIImageView, imageName: String, color: UIColor) {
        annotation.translatesAutoresizingMaskIntoConstraints = false
        annotation.image = UIImage(named: imageName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate).af_imageScaledToSize(CGSize(width: 10, height: 10)).tint(with: Color.white)
        annotation.backgroundColor = color
        annotation.contentMode = .center
        annotation.layer.cornerRadius = 7.5
        infoView.addSubview(annotation)
    }
    
    func prepareMoreButton() {
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.pulseColor = Color.grey.base
        moreButton.tintColor = Color.grey.lighten1
        moreButton.setImage(Icon.cm.moreVertical, for: UIControlState())
        moreButton.setImage(Icon.cm.moreVertical, for: .highlighted)
        moreButton.addTarget(self, action: #selector(T2GCell.moreButtonImagePressed(_:)), for: .touchUpInside)
        if mode == .table {
            backgroundView.addSubview(moreButton)
            backgroundView.addConstraints([ // MORE BUTTON
                NSLayoutConstraint(item: moreButton, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: moreButton, attribute: .trailing, relatedBy: .equal, toItem: backgroundView, attribute: .trailing, multiplier: 1, constant: -16)
                ])
        } else {
            whiteFooter.addSubview(moreButton)
            whiteFooter.addConstraints([ // MORE BUTTON
                NSLayoutConstraint(item: moreButton, attribute: .centerY, relatedBy: .equal, toItem: whiteFooter, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: moreButton, attribute: .trailing, relatedBy: .equal, toItem: whiteFooter, attribute: .trailing, multiplier: 1, constant: -8)
                ])
        }
    }
    
    func prepareSelectionButton() {
        let image = UIImage(named: "checkbox-marked-circle")?.withRenderingMode(.alwaysTemplate)
        if selected == nil {
            selectionButton.alpha = 0
            selectionButton.isHidden = true
            selectionButton.tintColor = Color.grey.base
        } else if selected == true {
            selectionButton.tintColor = Color.blue.base
        } else if selected == false {
            selectionButton.tintColor = Color.grey.base
        }
        selectionButton.pulseColor = Color.grey.base
        selectionButton.setImage(image, for: UIControlState())
        selectionButton.setImage(image, for: .highlighted)
        selectionButton.addTarget(self, action: #selector(T2GCell.selectionButtonPressed(_:)), for: .touchUpInside)
        selectionButton.translatesAutoresizingMaskIntoConstraints = false
        if mode == .table {
            backgroundView.addSubview(selectionButton)
            backgroundView.addConstraints([ // SELECTION BUTTON
                NSLayoutConstraint(item: selectionButton, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: selectionButton, attribute: .trailing, relatedBy: .equal, toItem: backgroundView, attribute: .trailing, multiplier: 1, constant: -16)
                ])
        } else {
            whiteFooter.addSubview(selectionButton)
            whiteFooter.addConstraints([ // SELECTION BUTTON
                NSLayoutConstraint(item: selectionButton, attribute: .centerY, relatedBy: .equal, toItem: whiteFooter, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: selectionButton, attribute: .trailing, relatedBy: .equal, toItem: whiteFooter, attribute: .trailing, multiplier: 1, constant: -8)
                ])
        }
    }
    
    func prepareHeaderLabel() {
        headerLabel.backgroundColor = .clear
        headerLabel.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        headerLabel.font = T2GStyle.Node.nodeTitleFont
        headerLabel.textColor = T2GStyle.Node.nodeTitleColor
        headerLabel.text = header
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        if mode == .table {
            backgroundView.addSubview(headerLabel)
            backgroundView.addConstraints([ // HEADER LABEL
                NSLayoutConstraint(item: headerLabel, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 20),
                NSLayoutConstraint(item: headerLabel, attribute: .trailing, relatedBy: .equal, toItem: backgroundView, attribute: .trailing, multiplier: 1, constant: -42),
                NSLayoutConstraint(item: headerLabel, attribute: .top, relatedBy: .equal, toItem: backgroundView, attribute: .top, multiplier: 1, constant: 20),
                ])
        } else {
            whiteFooter.addSubview(headerLabel)
            whiteFooter.addConstraints([ // HEADER LABEL
                NSLayoutConstraint(item: headerLabel, attribute: .leading, relatedBy: .equal, toItem: whiteFooter, attribute: .leading, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: headerLabel, attribute: .trailing, relatedBy: .equal, toItem: whiteFooter, attribute: .trailing, multiplier: 1, constant: -42),
                NSLayoutConstraint(item: headerLabel, attribute: .centerY, relatedBy: .equal, toItem: whiteFooter, attribute: .centerY, multiplier: 1, constant: 0),
                ])
        }
    }
    
    func prepareDetailLabel() {
        detailLabel.backgroundColor = .clear
        detailLabel.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        detailLabel.font = T2GStyle.Node.nodeDescriptionFont
        detailLabel.textColor = T2GStyle.Node.nodeDescriptionColor
        detailLabel.text = detail
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(detailLabel)
        backgroundView.addConstraints([ // DETAIL LABEL
            NSLayoutConstraint(item: detailLabel, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: detailLabel, attribute: .trailing, relatedBy: .equal, toItem: backgroundView, attribute: .trailing, multiplier: 1, constant: -42),
            NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .equal, toItem: headerLabel, attribute: .bottom, multiplier: 1, constant: 5),
            ])
    }
    
    open func cellSetSelected(_ selected: Bool) {
        self.selected = selected
        if self.selected! {
            selectionButton.tintColor = Color.blue.base
            delegate?.didCheckCell(tag)
        } else {
            selectionButton.tintColor = Color.grey.base
            delegate?.didUncheckCell(tag)
        }
    }
    
    /**
    Gets called when the cell has been pressed (standard tap gesture). Forwards the action to the delegate.
    
    :param: sender The button that initiated the action (that is a subview of backgroundView property).
    */
    func backgroundViewButtonPressed(_ sender: UIButton) {
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
    func changeFrameParadigm(_ mode: T2GLayoutMode, frame: CGRect) {
        self.frame = frame
        self.mode = mode
        renderCell()
    }
    
    /**
    Sets up buttons in drawer.
    
    :param: array of custom actions
    :param: mode T2GLayoutMode in which the T2GScrollView is.
    */
    open func setupActions(_ actions: [(title: String, image: UIImage, handler: (Void)->Void)], mode: T2GLayoutMode) {
        let a: (Void)->Void
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
            img = img.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            view.tintColor = T2GStyle.Node.nodeImageViewTintColor
            view.backgroundColor = .clear
            view.setBackgroundImage(img, for: UIControlState())
            view.setBackgroundImage(img, for: UIControlState.selected)
            view.setBackgroundImage(img, for: UIControlState.highlighted)
            view.handler = actions[index].handler
            view.addTarget(self, action: #selector(cellBackgroundButtonPressed(_:)), for: .touchUpInside)
            addSubview(view)
            sendSubview(toBack: view)
        }
        
        self.scrollView.contentSize = CGSize(width: frame.size.width * 2 - frame.size.height, height: frame.size.height)
    }
    
    /**
    Closes the drawer if it's opened.
    */
    func closeCell() {
        moveButtonsInHierarchy(true)
        swipeDirection = .right
        handleScrollEnd(scrollView)
    }
    
    /**
     Gets called when T2GCellDrawerButton has been pressed. Execute the handler and close the cell
     
     :param: sender T2GCellDrawerButton that has been pressed.
     */
    func cellBackgroundButtonPressed(_ sender: T2GCellDrawerButton) {
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
    func toggleMultipleChoice(_ flag: Bool, mode: T2GLayoutMode, selected: Bool, animated: Bool) {
        updateLayoutForEdit(flag, mode: mode, selected: selected, animated: animated)
    }
    
    func updateLayoutForEdit(_ flag: Bool, mode: T2GLayoutMode, selected: Bool, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        
        if flag {
            backgroundColor = .clear
        }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.moreButton.alpha = flag ? 0 : 1
            }, completion:  {(_) -> Void in
                self.moreButton.isHidden = flag
                self.selectionButton.isHidden = !flag
                UIView.animate(withDuration: duration, animations: { () -> Void in
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
    func coordinatesForButtons(_ count: Int, mode: T2GLayoutMode) -> (frames: [CGRect], offsetMultiplier: CGFloat) {
        let buttonSize: CGFloat = 12.0
        var coords: [CGRect] = []
        var multiplier: CGFloat = 1.0
        
        if mode == .table {
            let m = (frame.size.width - frame.size.height) / 4
            let margin = frame.height + m/2 - buttonSize / 2
            let y = (frame.size.height - CGFloat(buttonSize)) / 2.0
            
            for index in 0..<count {
                let x = margin + (m * CGFloat(index))
                coords.append(CGRect(x: x, y: y, width: buttonSize, height: buttonSize))
                multiplier = 1 + (1 - frame.height/frame.width)
            }
        } else {
            let padding = frame.height / 5 * 4 / 4
            let imgPadding = buttonSize / 2
            
            switch buttonCount {
            case 1...4:
                coords.append(CGRect(x: padding + imgPadding, y: padding + imgPadding, width: buttonSize, height: buttonSize))
                fallthrough
            case 2...4:
                coords.append(CGRect(x: padding * 3 - imgPadding, y: padding + imgPadding, width: buttonSize, height: buttonSize))
                fallthrough
            case 3,4:
                coords.append(CGRect(x: padding + imgPadding, y: padding * 3 - imgPadding, width: buttonSize, height: buttonSize))
                fallthrough
            case 4:
                coords.append(CGRect(x: padding * 3 - imgPadding, y: padding * 3 - imgPadding, width: buttonSize, height: buttonSize))
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
    func rearrangeButtons(_ mode: T2GLayoutMode) {
        let coordinateData = coordinatesForButtons(buttonCount, mode: mode)
        let origins = coordinateData.frames
        
        for index in 0..<buttonCount {
            if let view = viewWithTag(T2GViewTags.cellDrawerButtonConstant + index) as? T2GCellDrawerButton {
                let frame = origins[index]
                view.minOriginCoord = frame.origin
                view.frame = frame
            }
        }
        
        self.scrollView.contentSize = CGSize(width: frame.size.width * coordinateData.offsetMultiplier, height: frame.size.height)
    }
    
    func moreButtonImagePressed(_ sender: IconButton) {
//        self.delegate?.cellStartedSwiping(self.tag)
//        self.moveButtonsInHierarchy(true)
        if self.swipeDirection == .left {
            closeCell()
        } else if swipeDirection == .right {
            swipeDirection = .left
            handleScrollEnd(scrollView)
        }
    }
    
    func selectionButtonPressed(_ sender: IconButton) {
    
    }
    
    //MARK: - Scroll view delegate methods
    
    /**
    Helper method that handles the end of scroll motion - closes or opens the drawer.
    
    :param: scrollView The UIScrollView where scrolling motion happened.
    */
    func handleScrollEnd(_ scrollView: UIScrollView) {
        var x: CGFloat = 0
        if mode == .table {
            x = swipeDirection == .right ? 0 : frame.size.width - imageView.frame.size.width
        } else {
            x = swipeDirection == .right ? 0 : frame.size.width
        }
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        }, completion: { (_) -> Void in
            if self.swipeDirection == .right {
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
    func moveButtonsInHierarchy(_ shouldHide: Bool) {
        for index in 0...3 {
            if let view = viewWithTag(T2GViewTags.cellDrawerButtonConstant + index) as? T2GCellDrawerButton {
                if shouldHide {
                    sendSubview(toBack: view)
                } else {
                    bringSubview(toFront: view)
                }
            }
        }
    }
    
    /**
    Default Cocoa API - Tells the delegate when the scroll view is about to start scrolling the content.
    
    Informs the delegate that swiping motion began and moves buttons in hierarchy so they can be tapped.
    
    :param: scrollView The scroll-view object that is about to scroll the content view.
    */
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.cellStartedSwiping(tag)
        moveButtonsInHierarchy(true)
    }
    
    /**
    Default Cocoa API - Tells the delegate when dragging ended in the scroll view.
    
    If dragging stopped by user (= no deceleration), handleScrollEnd gets called (open/close so it doesn't stay half-way open).
    
    :param: scrollView The scroll-view object that finished scrolling the content view.
    :param: decelerate True if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
    */
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd(scrollView)
        }
    }
    
    /**
    Default Cocoa API - Tells the delegate that the scroll view is starting to decelerate the scrolling movement.
    
    Method handleScrollEnd gets called (open/close so it doesn't stay half-way open).
    
    :param: scrollView The scroll-view object that is decelerating the scrolling of the content view.
    */
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd(scrollView)
    }
    
    /**
    Default Cocoa API - Tells the delegate when a scrolling animation in the scroll view concludes.
    
    Shows buttons if the drawer was opened.
    
    :param: scrollView The scroll-view object that is performing the scrolling animation.
    */
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if swipeDirection == .left {
            moveButtonsInHierarchy(false)
        }
    }
    
    /**
    Default Cocoa API - Tells the delegate when the user scrolls the content view within the receiver.
    
    Animates buttons while scrollView gets scrolled (bigger while opening, smaller while closing). Also determines direction of the swipe.
    
    :param: scrollView The scroll-view object in which the scrolling occurred.
    */
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tailPosition = -scrollView.contentOffset.x + backgroundView.frame.size.width
        let sizeDifference = scrollView.contentOffset.x - lastContentOffset
        
        for index in 0..<buttonCount {
            if let button = viewWithTag(T2GViewTags.cellDrawerButtonConstant + index) as? T2GCellDrawerButton {
                button.resize(tailPosition, sizeDifference: sizeDifference)
            }
        }
        
        if lastContentOffset < scrollView.contentOffset.x && scrollView.contentOffset.x > scrollView.frame.width / 4 {
            swipeDirection = .left
        } else {
            swipeDirection = .right
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
    func addGestureRecognizerToView(_ recognizer: UILongPressGestureRecognizer) {
        scrollView.addGestureRecognizer(longPressGestureRecognizer!)
    }
}
