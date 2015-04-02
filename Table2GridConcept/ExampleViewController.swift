//
//  ViewController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 20/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class ExampleViewController: T2GViewController, T2GViewControllerDelegate {
    
    var modelArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0...127 {
            modelArray.append(index)
        }
        
        var rightButton_transform: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "transformView")
        var rightButton_toggle: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "toggleEdit")
        self.navigationItem.rightBarButtonItems = [rightButton_transform, rightButton_toggle]
        
        self.delegate = self
        //self.isHidingEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: T2GViewController delegate methods
    
    /// Datasource methods
    
    func cellForIndexPath(indexPath: NSIndexPath, frame: CGRect) -> T2GCell {
        let view = T2GCell(header: "R: \(self.modelArray[indexPath.row]) | T: \(indexPath.row + 333)", detail: "\(indexPath)", frame: frame, mode: self.layoutMode)
        view.setupButtons(indexPath.row%5, mode: self.layoutMode)
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
        cell.headerLabel?.text = "R: \(self.modelArray[indexPath.row]) | T: \(indexPath.row + 333)"
        cell.detailLabel?.text = "\(indexPath)"
    }
    
    /// View methods
    
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    func didSelectCellAtIndexPath(indexPath: NSIndexPath) {
        
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
}

