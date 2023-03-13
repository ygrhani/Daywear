//
//  CategoryListModel.swift
//  Daywear
//
//  Created by Ann Prudnikova on 13.03.23.
//

import Foundation
import Firebase


struct CategoryList {
    
    var title: String
    let userId: String
    let ref: DatabaseReference?
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
}
