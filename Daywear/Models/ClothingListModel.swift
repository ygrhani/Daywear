//
//  ClothingListModel.swift
//  Daywear
//
//  Created by Ann Prudnikova on 27.02.23.
//

import Foundation
import Firebase


struct ClothingList {
    
    var title: String
    let userId: String
    let ref: DatabaseReference?
    var imageName: String = ""
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init?(snapshot: DataSnapshot) { // DataSnapshot - снимок иерархии DB
        guard let snapshotValue = snapshot.value as? [String: Any],
              let title = snapshotValue[Constants.titleKey] as? String,
              let userId = snapshotValue[Constants.userIdKey] as? String,
              let imageName = snapshotValue[Constants.imageNameKey] as? String else { return nil }
        
        self.title = title
        self.userId = userId
        self.imageName = imageName
        ref = snapshot.ref
    }

    func convertToDictionary() -> [String: Any] {
        [Constants.titleKey: title, Constants.userIdKey: userId, Constants.imageNameKey: imageName]
    }

    // MARK: Private

    private enum Constants {
        static let titleKey = "title"
        static let userIdKey = "userId"
        static let imageNameKey = "imageName"
    }
}

