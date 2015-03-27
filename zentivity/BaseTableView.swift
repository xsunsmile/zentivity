//
//  BaseTableView.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

@objc protocol BaseTableViewDelegate: class {
    func cellDidSelected(tableView: UITableView, indexPath: NSIndexPath)
    optional func tableViewWillBeginDragging(scrollView: UIScrollView)
    optional func tableViewDidScroll(scrollView: UIScrollView)
}

class BaseTableView: NSObject,
                     UITableViewDataSource,
                     UITableViewDelegate
{
    var datasource: [AnyObject]!
    var titleSource: [NSString]!
    var cellIdentifier: NSString!
    var titleIdentifier: NSString?
    var cellHeight = CGFloat(150)
    weak var delegate: BaseTableViewDelegate?
    weak var controller: UIViewController?
    
    init(datasource: [AnyObject], cellIdentifier: NSString) {
        self.datasource = datasource
        self.cellIdentifier = cellIdentifier
        self.titleSource = []
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as BaseTableViewCell
        cell.data = datasource[indexPath.row]
        cell.controller = controller
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        (cell as BaseTableViewCell).refresh()
//    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.cellDidSelected(tableView, indexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if titleSource.count == 0 {
            return nil
        }
        return titleSource[section]
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return titleSource.count
    }
//    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if (editingStyle == UITableViewCellEditingStyle.Delete) {
//            datasource.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            tableView.reloadData()
//        }
//    }
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
//        var joinAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Join" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
//            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
//            
//            let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: nil)
//            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
//            
//            shareMenu.addAction(twitterAction)
//            shareMenu.addAction(cancelAction)
//        })
//        return [joinAction]
//    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let delegate = delegate {
            delegate.tableViewDidScroll!(scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let delegate = delegate {
            delegate.tableViewWillBeginDragging!(scrollView)
        }
    }
}
