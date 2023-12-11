//
//  Buoy.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct Buoy {
    let maxSpeed: Measurement<UnitSpeed>
    let maxRoll: Measurement<UnitAngle>
    let maxPitch: Measurement<UnitAngle>
    
    init(maxSpeed: Measurement<UnitSpeed>, maxRoll: Measurement<UnitAngle>, maxPitch: Measurement<UnitAngle>) {
        self.maxSpeed = maxSpeed
        self.maxRoll = maxRoll
        self.maxPitch = maxPitch
    }
}
