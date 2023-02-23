//
//  UserModel.swift
//  Daywear
//
//  Created by Ann Prudnikova on 8.02.23.
//

import Foundation
import Firebase

struct User {
    
    // MARK: Internal

    // идентификатор пользователя
    let uid: String
    let email: String
    
    
    // MARK: Lifecycle


    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }
}
