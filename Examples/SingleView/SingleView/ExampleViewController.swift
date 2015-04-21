//
//  ViewController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 20/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class ExampleViewController: T2GViewController, T2GViewControllerDelegate, T2GDropDelegate {
    
    var modelArray: [Int] = []
    var modelArray2: [Int] = []
    var modelArray3: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0..<10 {
            modelArray.append(index)
            modelArray2.append(index)
            modelArray3.append(index)
        }
        
        var rightButton_transform: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "transformView")
        var rightButton_toggle: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "toggleEdit")
        self.navigationItem.rightBarButtonItems = [rightButton_transform, rightButton_toggle]
        
        self.isHidingEnabled = true
        
        if let navCtr = self.navigationController as? T2GNaviViewController {
            self.statusBarBackgroundView = navCtr.addStatusBarBackgroundView()
            
            navCtr.navigationBar.barTintColor = self.statusBarBackgroundViewColor
            navCtr.navigationBar.tintColor = .whiteColor()
        }
        
        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl!.addTarget(self, action: "handlePullToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.refreshControl!.tag = T2GViewTags.refreshControl.rawValue
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.delegate == nil {
            self.delegate = self
            self.dropDelegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handlePullToRefresh(sender: UIRefreshControl) {
        //sender.attributedTitle = NSAttributedString(string: "\n Refreshing")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            NSThread.sleepForTimeInterval(1.5)
            dispatch_async(dispatch_get_main_queue(), {
                let formatter = NSDateFormatter()
                formatter.dateStyle = .MediumStyle
                let lastUpdate = String(format:"Last updated on %@", formatter.stringFromDate(NSDate()))
                sender.attributedTitle = NSAttributedString(string: lastUpdate)
                self.automaticSnapStatus = .WillSnap
                
                self.reloadScrollView()
                sender.endRefreshing()
            });
        });
    }
    
    //MARK: T2GViewController delegate methods
    
    /// Datasource methods
    
    func cellForIndexPath(indexPath: NSIndexPath, frame: CGRect) -> T2GCell {
        var view: T2GCell?
        switch(indexPath.section) {
        case 0:
            view = T2GCell(header: "R: \(self.modelArray[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant.rawValue)", detail: "\(indexPath)", frame: frame, mode: self.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        case 1:
            view = T2GCell(header: "R: \(self.modelArray2[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant.rawValue)", detail: "\(indexPath)", frame: frame, mode: self.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        case 2:
            view = T2GCell(header: "R: \(self.modelArray3[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant.rawValue)", detail: "\(indexPath)", frame: frame, mode: self.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        default:
            view = T2GCell(header: "", detail: "\(indexPath)", frame: frame, mode: self.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        }
        
        return view!
    }
    
    func numberOfSectionsInT2GView() -> Int {
        return 3
    }
    
    func numberOfCellsInSection(section: Int) -> Int {
        switch(section) {
        case 0:
            return self.modelArray.count
        case 1:
            return self.modelArray2.count
        case 2:
            return self.modelArray3.count
        default:
            return 0
        }
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return "Section #\(section + 1)"
    }
    
    func updateCellForIndexPath(cell: T2GCell, indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case 0:
            cell.headerLabel?.text = "R: \(self.modelArray[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant.rawValue)"
            cell.detailLabel?.text = "\(indexPath)"
            break
        case 1:
            cell.headerLabel?.text = "R: \(self.modelArray2[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant.rawValue)"
            cell.detailLabel?.text = "\(indexPath)"
            break
        case 2:
            cell.headerLabel?.text = "R: \(self.modelArray3[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant.rawValue)"
            cell.detailLabel?.text = "\(indexPath)"
            break
        default:
            break
        }
    }
    
    /// View methods
    
    func cellPadding(mode: T2GLayoutMode) -> CGFloat {
        return 12.0
    }
    
    func dimensionsForCell(mode: T2GLayoutMode) -> CGSize {
        if mode == .Collection {
            return CGSizeMake(98, 98)
        } else {
            return CGSizeMake(self.view.frame.size.width * 0.9, 64.0)
        }
    }
    
    func dimensionsForSectionHeader() -> CGSize {
        return CGSize(width: 300, height: 32.0)
    }
    
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    func didSelectCellAtIndexPath(indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let newVC: ExampleViewController = storyboard.instantiateViewControllerWithIdentifier("ExampleVC") as ExampleViewController
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func willDeselectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    func didDeselectCellAtIndexPath(indexPath: NSIndexPath) {
        //
    }
    
    func didSelectDrawerButtonAtIndex(indexPath: NSIndexPath, buttonIndex: Int) {
        if buttonIndex == 0 {
            switch(indexPath.section) {
            case 0:
                self.modelArray.removeAtIndex(indexPath.row)
                break
            case 1:
                self.modelArray2.removeAtIndex(indexPath.row)
                break
            case 2:
                self.modelArray3.removeAtIndex(indexPath.row)
                break
            default:
                break
            }
            
            self.removeRowsAtIndexPaths([indexPath])
        } else if buttonIndex == 1 {
            switch(indexPath.section) {
            case 0:
                self.modelArray.insert(42, atIndex: indexPath.row + 1)
                break
            case 1:
                self.modelArray2.insert(42, atIndex: indexPath.row + 1)
                break
            case 2:
                self.modelArray3.insert(42, atIndex: indexPath.row + 1)
                break
            default:
                break
            }
            
            let indexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
            self.insertRowAtIndexPath(indexPath)
        } else {
            self.toggleEditingMode(!self.isEditingModeActive)
        }
    }
    
    func willRemoveCellAtIndexPath(indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case 0:
            self.modelArray.removeAtIndex(indexPath.row)
            break
        case 1:
            self.modelArray2.removeAtIndex(indexPath.row)
            break
        case 2:
            self.modelArray3.removeAtIndex(indexPath.row)
            break
        default:
            break
        }
    }
    
    //MARK: T2GDrop delegate methods
    
    func didDropCell(cell: T2GCell, onCell: T2GCell, completion: () -> Void, failure: () -> Void) {
        if onCell.tag % 2 != 0 {
            failure()
        } else {
            let indexPath = self.scrollView.indexPathForCell(cell.tag)
            self.modelArray.removeAtIndex(indexPath.row)
            completion()
        }
    }
}

