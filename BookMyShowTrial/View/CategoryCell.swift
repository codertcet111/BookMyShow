//
//  CategoryCell.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var productCollectionView: ProductsCollectionView!
    
    @IBOutlet weak var collectionHeaderview: UIView!
    @IBOutlet weak var categoryTitleLabelOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}

extension CategoryCell{
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDelegate & UICollectionViewDataSource>(_ dataSourceDelegate: D, forRow row:Int){
        productCollectionView.delegate = dataSourceDelegate
        productCollectionView.dataSource = dataSourceDelegate
        productCollectionView.tag = row
        productCollectionView.reloadData()
    }
    
}
