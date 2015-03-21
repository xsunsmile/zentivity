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
    var cellHeight = CGFloat(100)
    weak var delegate: BaseTableViewDelegate?
    
    init(datasource: [AnyObject], cellIdentifier: NSString) {
        self.datasource = datasource
        self.cellIdentifier = cellIdentifier
        self.titleSource = []
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as BaseTableViewCell
        cell.data = datasource[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as BaseTableViewCell).refresh()
    }
    
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
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if titleIdentifier == nil {
//            return nil
//        }
//        
//        var cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(titleIdentifier!) as EventHeaderTableViewCell
//        cell.frame.size.width = tableView.frame.width
//        return cell
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 34
//    }
}
