//
//  FriendPickerCell.swift
//  zentivity
//
//  Created by Eric Huang on 3/22/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class FriendPickerCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    var user: User? { didSet { handleUserDidSet() } }
    var selectionStatus: Bool = false { didSet { setSelectionStyle() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func handleUserDidSet() {
        nameLabel.text = user?.name
        setNeedsDisplay()
    }
    
    func setSelectionStyle() {
        if selectionStatus {
            accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            accessoryType = UITableViewCellAccessoryType.None
        }
    }
}
