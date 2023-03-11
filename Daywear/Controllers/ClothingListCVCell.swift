//
//  ClothingListCVCell.swift
//  Daywear
//
//  Created by Ann Prudnikova on 27.02.23.
//

import UIKit
import FirebaseDatabase

class ClothingListCVCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    view?.layer.cornerRadius = 25
    
    var menuCategory: ClothingList? {
        didSet {
            categoryName.text = menuCategory?.title
            if let image = menuCategory?.imageName {
                categoryImage.image = UIImage(named: image)
            }
        }
    }
}
