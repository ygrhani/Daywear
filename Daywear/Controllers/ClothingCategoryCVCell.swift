//
//  ClothingCategoryCVCell.swift
//  Daywear
//
//  Created by Ann Prudnikova on 20.03.23.
//

import UIKit

class ClothingCategoryCVCell: UICollectionViewCell {
    
    
    @IBOutlet weak var picOfClothes: UIImageView!
    @IBOutlet weak var selectLbl: UILabel!    
    var isEditing: Bool = false {
        didSet {
            selectLbl.isHidden = !isEditing
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isEditing {
                selectLbl.text = isEditing ? "✓" : ""
            }
        }
    }
    
    override func awakeFromNib() {
        
        self.selectLbl.layer.cornerRadius = 15
        self.selectLbl.layer.masksToBounds = true
        self.selectLbl.layer.borderColor = UIColor.white.cgColor
        self.selectLbl.layer.borderWidth = 1.0
        self.selectLbl.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selectLbl.isHidden = !isEditing
        
    }
}


