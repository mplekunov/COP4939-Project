//
//  File.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct Boat {
    let name: String
    let driver: BoatDriver
    
    init(name: String, driver: BoatDriver) {
        self.name = name
        self.driver = driver
    }
}
