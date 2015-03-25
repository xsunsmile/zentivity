//
//  Theme.swift
//  zentivity
//
//  Created by Andrew Wen on 3/24/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import Foundation
import UIKit

// https://garden.zendesk.com/colors

class Themes {
    class func primaryColor() -> UIColor {
        return Colors().zendeskGreen
    }
    
    class func secondaryBlueColor() -> UIColor {
        return Colors().malibu
    }
    
    class func secondaryPurpleColor() -> UIColor {
        return Colors().deepLilac
    }
    
    class func secondaryRedColor() -> UIColor {
        return Colors().cgRed
    }
    
    class func secondaryYellowColor() -> UIColor {
        return Colors().sunGlow
    }
    
    class func backgroundTexture() -> UIColor {
        return Colors().texturedGray
    }
}

class Colors {
    // PRIMARY COLORS
    
    let zendeskGreen =  UIColor(rgb: 0x78a300)
    let promoORange =  UIColor(rgb: 0xffa100)
    let darkPastelRed =  UIColor(rgb: 0xbf3026)
    
    // SECONDARY: Blues
    
    let malibu =  UIColor(rgb: 0x5ebbde)
    let patternsBlue =  UIColor(rgb: 0xd2eef9)
    
    // SECONDARY: Purples
    
    let deepLilac =  UIColor(rgb: 0x965ab6)
    let blueChalk =  UIColor(rgb: 0xe5d6ed)
    
    // SECONDARY: Reds
    
    let cgRed =  UIColor(rgb: 0xe03b30)
    let remy =  UIColor(rgb: 0xf7cecb)
    
    // SECONDARY: Yellows
    
    let sunGlow =  UIColor(rgb: 0xFFD12A)
    let lemonChiffon =  UIColor(rgb: 0xFFF3CA)
    
    // GRAYSCALE
    
    let darkGray =  UIColor(rgb: 0x555555)
    let gainsboro =  UIColor(rgb: 0xDDDDDD)
    let whiteSmoke =  UIColor(rgb: 0xF8F8F8)
    
    // PATTERNS
    
    let tasticGray =  UIColor(patternImage: UIImage(named: "texture_tastic_gray")!)
    let texturedGray =  UIColor(patternImage: UIImage(named: "bgT1")!)
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
