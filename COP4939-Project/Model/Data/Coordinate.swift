//
//  Coordinate.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation

struct Coordinate : Codable, Equatable {
    let longitude: Measurement<UnitAngle>
    let latitude: Measurement<UnitAngle>
}
