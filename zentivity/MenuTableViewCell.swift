//
//  MenuTableViewCell.swift
//  zentivity
//
//  Created by Andrew Wen on 3/5/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class MenuTableViewCell: BaseTableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func onDataSet(data: AnyObject!) {
        let dict = data as! NSDictionary
        iconImageView.image = UIImage(named: dict["icon"] as! NSString as String)
        iconImageView.layer.opacity = 0.3
        itemLabel.text = dict["title"] as! NSString as String
    }
    
    override func refresh() {
    }
}
