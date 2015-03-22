//
//  SearchFilterView.swift
//  zentivity
//
//  Created by Hao Sun on 3/22/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

protocol SearchFilterViewDelegate: class {
    func onSearchFilterPress()
}

class SearchFilterView: UIView {

    var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate: SearchFilterViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    func initSubViews() {
        let nib = UINib(nibName: "SearchFilterView", bundle: nil)
        let objects = nib.instantiateWithOwner(self, options: nil)
        contentView = objects[0] as UIView
        contentView.frame = bounds
        
        searchBar.barTintColor = UIColor.clearColor()
        searchBar.backgroundImage = UIImage()
        
        addSubview(contentView)
    }

    @IBAction func onFilterPress(sender: AnyObject) {
        delegate?.onSearchFilterPress()
    }
}
