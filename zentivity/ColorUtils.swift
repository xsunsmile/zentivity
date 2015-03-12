//
//  ColorUtils.swift
//  zentivity
//
//  Created by Hao Sun on 3/11/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class ColorUtils: NSObject {
    class func greyGradient() -> CAGradientLayer {
        var colors =  NSArray(array: [
//                  UIColor(white: 0.1, alpha: alpha).CGColor,
//                  UIColor(hue: 0.625, saturation: 0.0, brightness: 0.85, alpha: alpha).CGColor,
//                  UIColor(hue: 0.625, saturation: 0.0, brightness: 0.7, alpha: alpha).CGColor,
//                  UIColor(hue: 0.625, saturation: 0.0, brightness: 0.4, alpha: alpha).CGColor
                    UIColor.clearColor().CGColor,
                    UIColor.blackColor().CGColor
            ])
        
        var locations = NSArray(array: [
                NSNumber(float: 0.0),
                NSNumber(float: 0.02),
                NSNumber(float: 0.79),
                NSNumber(float: 1.0)
            ])
        
        var layer = CAGradientLayer()
        layer.colors = colors;
        layer.startPoint = CGPointMake(1.0, 0.8)
        layer.endPoint = CGPointMake(1.0, 1.0)
//        layer.locations = locations;
        
        return layer;
    }
}
