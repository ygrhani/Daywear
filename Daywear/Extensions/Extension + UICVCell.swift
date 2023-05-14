//
//  Extension + UICVCell.swift
//  Daywear
//
//  Created by Ann Prudnikova on 28.03.23.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    func makeCell() {
        self.backgroundColor = #colorLiteral(red: 0.9905706048, green: 0.7712565817, blue: 0.732809884, alpha: 1)
        self.layer.cornerRadius = 37
        self.layer.borderWidth = 4
        self.layer.borderColor = #colorLiteral(red: 0.7981536575, green: 0.6121546785, blue: 0.6574791391, alpha: 1)
    }
}
