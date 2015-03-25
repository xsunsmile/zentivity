//
//  EmptyTableView.swift
//  zentivity
//
//  Created by Hao Sun on 3/21/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

protocol EmptyTableViewDelegate : class {
    func onCTA(action: NSString)
}

class EmptyTableView: UIView {

    var contentView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var ctaButton: UIButton!
    
    var delegate: EmptyTableViewDelegate?
    
    var message : NSString = "" {
        didSet {
            messageLabel.text = message
        }
    }
    
    var buttonLabel : NSString = "" {
        didSet {
            ctaButton.setTitle(buttonLabel, forState: .Normal)
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    func initSubViews() {
        let nib = UINib(nibName: "EmptyTableView", bundle: nil)
        let objects = nib.instantiateWithOwner(self, options: nil)
        contentView = objects[0] as UIView
        contentView.frame = bounds
        
        addSubview(contentView)
    }
    
    @IBAction func onButtonPress(sender: UIButton) {
        delegate?.onCTA(sender.titleLabel!.text!)
    }
}
