//
//  ColorUtils.swift
//  zentivity
//
//  Created by Hao Sun on 3/11/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class ImageUtils: NSObject {
    class func makeRoundImageWithBorder(view: UIView, borderColor: CGColor) {
        view.layer.cornerRadius = view.frame.size.width/2
        view.clipsToBounds = true
        view.layer.borderWidth = 3.0;
        view.layer.borderColor = borderColor
    }
    
    class func makeRoundCornerWithBorder(view: UIView, borderColor: CGColor, borderWidth: CGFloat) {
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = borderColor
    }
    
    class func addShadow(view: UIView, color: CGColor, size: CGSize, radius: CGFloat) {
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(5, 5)
        view.layer.shadowRadius = 5
    }
}
