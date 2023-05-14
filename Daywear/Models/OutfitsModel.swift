//
//  OutfitsModel.swift
//  Daywear
//
//  Created by Ann Prudnikova on 24.03.23.
//

import Foundation
import Firebase

struct OutfitsList {
    
    var outfits: String
    let userId: String
    let ref: DatabaseReference?
    
    init(userId: String, outfits: String) {
        self.userId = userId
        self.ref = nil
        self.outfits = outfits
    }
    
    init?(snapshot: DataSnapshot) { // DataSnapshot - снимок иерархии DB
        guard let snapshotValue = snapshot.value as? [String: Any],
              let outfits = snapshotValue[Constants.outfitsKey] as? String,
              let userId = snapshotValue[Constants.userIdKey] as? String else { return nil }
        
        self.outfits = outfits
        self.userId = userId
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> [String: Any] {
        [Constants.outfitsKey: outfits, Constants.userIdKey: userId]
    }

    // MARK: Private

    private enum Constants {
        static let outfitsKey = "outfitsKey"
        static let userIdKey = "userId"
        static let imageNameKey = "imageName"
    }
}

