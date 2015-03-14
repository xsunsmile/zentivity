//
//  ShadowButton.swift
//  zentivity
//
//  Created by Hao Sun on 3/14/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class ShadowButton: UIButton {
    
    var cornerRadius: CGFloat? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        cornerRadius = frame.width/2
    }
    
    override func drawRect(rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius!
        
        //superview is your optional embedding UIView
        if let superview = superview {
            superview.backgroundColor = UIColor.clearColor()
            superview.layer.shadowColor = UIColor.blackColor().CGColor
            superview.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius!).CGPath
            superview.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
            superview.layer.shadowOpacity = 0.7
            superview.layer.shadowRadius = 1
            superview.layer.masksToBounds = true
            superview.clipsToBounds = false
        }
    }
}
