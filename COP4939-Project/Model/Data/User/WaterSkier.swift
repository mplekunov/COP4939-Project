//
//  WaterSkier.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/12/23.
//

import Foundation

class WaterSkier : User {
    let ageGroup: WaterSkiingAgeGroup
    let ski: Ski
    let fin: Fin
    
    init(user: User, ageGroup: WaterSkiingAgeGroup, ski: Ski, fin: Fin) {
        self.ageGroup = ageGroup
        self.ski = ski
        self.fin = fin
        
        super.init(name: user.name, dateOfBirth: user.dateOfBirth, username: user.username, password: user.password)
    }
}
