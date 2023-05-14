//
//  CategoryListModel.swift
//  Daywear
//
//  Created by Ann Prudnikova on 13.03.23.
//

import Foundation
import Firebase


struct CategoryList {
    
    var itemsCategory: String?
    var itemsCategoryUUID: String
    let userId: String
    let ref: DatabaseReference?
    
    init(itemsCategory: String, itemsCategoryUUID: String, userId: String) {
        self.itemsCategory = itemsCategory
        self.itemsCategoryUUID = itemsCategoryUUID
        self.userId = userId
        self.ref = nil
    }
    
    init?(snapshot: DataSnapshot) { // DataSnapshot - снимок иерархии DB
        guard let snapshotValue = snapshot.value as? [String: Any],
              let itemsCategory = snapshotValue[Constants.itemsCategoryKey] as? String,
              let itemsCategoryUUID = snapshotValue[Constants.itemsCategoryUUIDKey] as? String,
              let userId = snapshotValue[Constants.userIdKey] as? String else { return nil }
        
        self.itemsCategory = itemsCategory
        self.itemsCategoryUUID = itemsCategoryUUID
        self.userId = userId
        ref = snapshot.ref
    }

    func convertToDictionary() -> [String: Any] {
        [Constants.itemsCategoryKey: itemsCategory!, Constants.itemsCategoryUUIDKey: itemsCategoryUUID, Constants.userIdKey: userId]
    }

    // MARK: Private

    private enum Constants {
        static let itemsCategoryKey = "itemsCategory"
        static let userIdKey = "userId"
        static let imageNameKey = "imageName"
        static let itemsCategoryUUIDKey = "itemsCategoryUUIDKey"
    }
}

