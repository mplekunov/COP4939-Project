//
//  User.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/12/23.
//

import Foundation

class User {
    let name: String
    let dateOfBirth: Date
    let username: String
    let password: String
    
    init(name: String, dateOfBirth: Date, username: String, password: String) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.username = username
        self.password = password
    }
}
