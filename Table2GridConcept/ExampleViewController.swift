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
        
        self.delegate = self
        //self.isHidingEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: T2GViewController delegate methods
    
    /// Datasource methods
    
    func cellForIndexPath(indexPath: NSIndexPath) -> T2GCell {
        let frame = self.frameForCell(self.layoutMode, yOffset: 12, index: indexPath.row)
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
        
    }
    
    func didSelectDrawerButtonAtIndex(indexPath: NSIndexPath, buttonIndex: Int) {
        self.modelArray.removeAtIndex(indexPath.row)
        self.removeRowAtIndexPath(indexPath)
    }
}

