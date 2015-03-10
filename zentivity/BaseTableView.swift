//
//  BaseTableView.swift
//  zentivity
//
//  Created by Hao Sun on 3/8/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class BaseTableView: NSObject,
                     UITableViewDataSource,
                     UITableViewDelegate
{
    var datasource: [AnyObject]!
    var cellIdentifier: NSString!
    var cellHeight = CGFloat(100)
    
    init(datasource: [NSDictionary], cellIdentifier: NSString) {
        self.datasource = datasource
        self.cellIdentifier = cellIdentifier
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
}
