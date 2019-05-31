//
//  CategoryCell.swift
//  BookMyShowTrial
//
//  Created by Shubham Mishra on 30/05/19.
//  Copyright © 2019 Shubham Mishra. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    //IMPORTANT: This tableViewCell is containing CollectionView
    @IBOutlet weak var productCollectionView: ProductsCollectionView!
    
    @IBOutlet weak var collectionHeaderview: UIView!{
        didSet{
            collectionHeaderview.layer.borderWidth = 0.5
            collectionHeaderview.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var categoryTitleLabelOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}

//The below function will set the delegate for collectionview
extension CategoryCell{
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDelegate & UICollectionViewDataSource>(_ dataSourceDelegate: D, forRow row:Int){
        productCollectionView.delegate = dataSourceDelegate
        productCollectionView.dataSource = dataSourceDelegate
        productCollectionView.tag = row
        productCollectionView.reloadData()
    }
    
}
