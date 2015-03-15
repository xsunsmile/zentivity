//
//  UIViewExtension.swift
//  zentivity
//
//  Created by Hao Sun on 3/15/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

extension UIView {
    func convertToImage() -> UIImage {
        var size = bounds.size;
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}