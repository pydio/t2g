//
//  ViewController.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 20/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

/**
...
*/
class ExampleViewController: T2GViewController, T2GViewControllerDelegate, T2GDropDelegate, T2GScrollViewDataDelegate, T2GNavigationBarMenuDelegate {
    
    var detailViewController: DetailViewController? = nil
    
    var modelArray: [Int] = []
    var modelArray2: [Int] = []
    var modelArray3: [Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    /**
    ...
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count - 1].topViewController as? DetailViewController
        }
        
        for index in 0..<10 {
            modelArray.append(index)
            modelArray2.append(index)
            modelArray3.append(index)
        }
        
        var rightButton_transform: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "transformView")
        var rightButton_toggle: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "toggleEdit")
        var rightButton_menu: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self.navigationController!, action: "toggleBarMenu")
        self.navigationItem.rightBarButtonItems = [rightButton_transform, rightButton_toggle, rightButton_menu]
        
        self.isHidingEnabled = false
        
        if let navCtr = self.navigationController as? T2GNaviViewController {
            navCtr.menuDelegate = self
            navCtr.navigationBar.barTintColor = self.statusBarBackgroundViewColor
            navCtr.navigationBar.tintColor = .whiteColor()
        }
        
        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl!.addTarget(self, action: "handlePullToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.refreshControl!.tag = T2GViewTags.refreshControl
    }
    
    /**
    ...
    */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.delegate == nil {
            self.scrollView.dataDelegate = self
            self.delegate = self
            self.dropDelegate = self
        }
    }
    
    /**
    ...
    */
    override func viewWillAppear(animated: Bool) {
        self.scrollView.alignVisibleCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    ...
    
    :param: sender
    */
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
    
    /**
    ...
    
    :param: indexPath
    :param: frame
    :returns:
    */
    func cellForIndexPath(indexPath: NSIndexPath, frame: CGRect) -> T2GCell {
        var view: T2GCell?
        switch(indexPath.section) {
        case 0:
            view = T2GCell(header: "R: \(self.modelArray[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant)", detail: "\(indexPath)", frame: frame, mode: self.scrollView.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.scrollView.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        case 1:
            view = T2GCell(header: "R: \(self.modelArray2[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant)", detail: "\(indexPath)", frame: frame, mode: self.scrollView.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.scrollView.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        case 2:
            view = T2GCell(header: "R: \(self.modelArray3[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant)", detail: "\(indexPath)", frame: frame, mode: self.scrollView.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.scrollView.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        default:
            view = T2GCell(header: "", detail: "\(indexPath)", frame: frame, mode: self.scrollView.layoutMode)
            view!.setupButtons(indexPath.row%5, mode: self.scrollView.layoutMode)
            view!.draggable = true
            view!.draggableDelegate = self
            break
        }
        
        return view!
    }
    
    /**
    ...
    
    :returns:
    */
    func numberOfSections() -> Int {
        return 3
    }
    
    /**
    ...
    
    :param: section
    :returns:
    */
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
    
    /**
    ...
    
    :param: section
    :returns:
    */
    func titleForHeaderInSection(section: Int) -> String? {
        return "Section #\(section + 1)"
    }
    
    /**
    ...
    
    :param: cell
    :param: indexPath
    */
    func updateCellForIndexPath(cell: T2GCell, indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case 0:
            cell.headerLabel?.text = "R: \(self.modelArray[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant)"
            cell.detailLabel?.text = "\(indexPath)"
            break
        case 1:
            cell.headerLabel?.text = "R: \(self.modelArray2[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant)"
            cell.detailLabel?.text = "\(indexPath)"
            break
        case 2:
            cell.headerLabel?.text = "R: \(self.modelArray3[indexPath.row]) | S: \(indexPath.section) | T: \(self.scrollView.indexForIndexPath(indexPath) + T2GViewTags.cellConstant)"
            cell.detailLabel?.text = "\(indexPath)"
            break
        default:
            break
        }
    }
    
    /// View methods
    
    /**
    ...
    
    :param: mode
    :returns:
    */
    func dimensionsForCell(mode: T2GLayoutMode) -> (width: CGFloat, height: CGFloat, padding: CGFloat) {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if mode == .Collection {
            width = 94.0
            height = 94.0
        } else {
            width = self.scrollView.frame.size.width * 0.9
            height = 64.0
        }
        
        return (width, height, 12.0)
    }
    
    /**
    ...
    
    :returns:
    */
    func dimensionsForSectionHeader() -> CGSize {
        return CGSize(width: 300, height: 32.0)
    }
    
    /**
    ...
    
    :param: indexPath
    :returns:
    */
    func willSelectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    /**
    ...
    
    :param: indexPath
    */
    func didSelectCellAtIndexPath(indexPath: NSIndexPath) {
        if indexPath.row%2 == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let newVC: ExampleViewController = storyboard.instantiateViewControllerWithIdentifier("ExampleVC") as ExampleViewController
            self.navigationController?.pushViewController(newVC, animated: true)
        } else {
            self.tabBarController?.performSegueWithIdentifier("showDetail", sender: nil)
        }
        
        
    }
    
    /**
    ...
    
    :param: indexPath
    :returns:
    */
    func willDeselectCellAtIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    /**
    ...
    
    :param: indexPath
    */
    func didDeselectCellAtIndexPath(indexPath: NSIndexPath) {
        //
    }
    
    /**
    ...
    
    :param: indexPath
    :param: buttonIndex
    */
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
            self.toggleEdit()
        }
    }
    
    /**
    ...
    
    :param: indexPath
    */
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
    
    /**
    ...
    
    :param: cell
    :param: onCell
    :param: completion
    :param: failure
    */
    func didDropCell(cell: T2GCell, onCell: T2GCell, completion: () -> Void, failure: () -> Void) {
        if onCell.tag % 2 != 0 {
            failure()
        } else {
            let indexPath = self.scrollView.indexPathForCell(cell.tag)
            
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
            
            completion()
        }
    }
    
    //MARK: - T2GNavigationBarMenu delegate method
    
    /**
    ...
    
    :param: index
    :returns:
    */
    func viewForCell(index: Int, size: CGSize) -> UIView {
        let view = UIView(frame: CGRectMake(0.0, 0.0, size.width, size.height))
        let ivSize = size.height * 0.7
        let imageView = UIImageView(frame: CGRectMake(10.0, (size.height - ivSize) / CGFloat(2.0), ivSize, ivSize))
        imageView.backgroundColor = .blackColor()
        view.addSubview(imageView)
        return view
    }
    
    /**
    ...
    
    :param: index
    */
    func didSelectButton(index: Int) {
        println(index)
        (self.navigationController? as T2GNaviViewController).toggleBarMenu(true)
    }
}

