//
//  UserIconCollectionViewCell.swift
//  zentivity
//
//  Created by Hao Sun on 3/11/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class UserIconCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var user: User? {
        didSet {
            user?.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                if error == nil {
                    self.userNameLabel.hidden = true
                    let user = user as User
                    if user.imageUrl?.length > 0 {
                        let url = NSURL(string: user.imageUrl!)
                        self.userImageView.setImageWithURL(url)
                    } else {
                        let initialsImage = user.initialsImageView(self.userImageView.frame.size)
                        self.userImageView.image = initialsImage
                    }
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ImageUtils.makeRoundImageWithBorder(userImageView, borderColor: UIColor.whiteColor().CGColor)
    }
}
