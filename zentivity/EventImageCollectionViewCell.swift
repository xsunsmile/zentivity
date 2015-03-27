//
//  EventImageCollectionViewCell.swift
//  zentivity
//
//  Created by Hao Sun on 3/26/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class EventImageCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        initSubView()
    }
    
    func initSubView() {
        frame = CGRectMake(0, 0, 80, 80)
    }

}
