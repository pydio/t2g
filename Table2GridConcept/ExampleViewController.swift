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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0...25 {
            modelArray.append(index)
        }
        
        var rightButton_transform: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "transformView")
        var rightButton_toggle: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "toggleEdit")
        self.navigationItem.rightBarButtonItems = [rightButton_transform, rightButton_toggle]
        
        self.isHidingEnabled = true
        
        if let navCtr = self.navigationController as? T2GNaviViewController {
            self.statusBarBackgroundView = navCtr.addStatusBarBackgroundView()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handlePullToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl!.tag = 987654
        self.scrollView.addSubview(self.refreshControl!)
        
        self.delegate = self
        self.dropDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: T2GViewController delegate methods
    
    /// Datasource methods
    
    func cellForIndexPath(indexPath: NSIndexPath, frame: CGRect) -> T2GCell {
        let view = T2GCell(header: "R: \(self.modelArray[indexPath.row]) | T: \(indexPath.row + T2GViewTags.cellConstant.rawValue)", detail: "\(indexPath)", frame: frame, mode: self.layoutMode)
        view.setupButtons(indexPath.row%5, mode: self.layoutMode)
        view.draggable = true
        view.draggableDelegate = self
        return view
    }
    
    func numberOfSectionsInT2GView() -> Int {
        return 1
    }
    
    func numberOfCellsInSection(section: Int) -> Int {
        return self.modelArray.count
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return ""
    }
    
    func updateCellForIndexPath(cell: T2GCell, indexPath: NSIndexPath) {
        cell.headerLabel?.text = "R: \(self.modelArray[indexPath.row]) | T: \(indexPath.row + T2GViewTags.cellConstant.rawValue)"
        cell.detailLabel?.text = "\(indexPath)"
    }
    
    /// View methods
    
    func cellPadding(mode: T2GLayoutMode) -> CGFloat {
        return 12.0
    }
    
    func dimensionsForCell(mode: T2GLayoutMode) -> CGSize {
        if mode == .Collection {
            return CGSizeMake(100, 100)
        } else {
            return CGSizeMake(self.view.frame.size.width * 0.9, 64.0)
        }
    }
    
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    func didSelectCellAtIndexPath(indexPath: NSIndexPath) {
        println(indexPath)
        
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
            self.modelArray.removeAtIndex(indexPath.row)
            self.removeRowAtIndexPath(indexPath)
        } else if buttonIndex == 1 {
            self.modelArray.insert(42, atIndex: indexPath.row + 1)
            let indexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: 0)
            self.insertRowAtIndexPath(indexPath)
        } else {
            self.toggleEditingMode(!self.isEditingModeActive)
        }
    }
    
    func willRemoveCellAtIndexPath(indexPath: NSIndexPath) {
        self.modelArray.removeAtIndex(indexPath.row)
    }
    
    func setupViewForStatusBarBackground(view: UIView) -> UIView? {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07)
        return view
    }
    
    //MARK: T2GDrop delegate methods
    
    func didDropCell(cell: T2GCell, onCell: T2GCell, completion: () -> Void, failure: () -> Void) {
        if onCell.tag % 2 != 0 {
            failure()
        } else {
            self.modelArray.removeAtIndex(cell.tag - T2GViewTags.cellConstant.rawValue)
            completion()
        }
    }
}

