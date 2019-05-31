//
//  reviewCollectionViewCell.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import UIKit

class reviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userrReviewTextLabel: UILabel!{
        didSet{
            userrReviewTextLabel.layer.cornerRadius = 8.0
            userrReviewTextLabel.clipsToBounds = true
        }
    }
    
}
