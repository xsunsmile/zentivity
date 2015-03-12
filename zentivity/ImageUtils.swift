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
}
