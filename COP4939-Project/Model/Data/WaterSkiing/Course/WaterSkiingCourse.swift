//
//  WaterSkiingCourse.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/13/23.
//

import Foundation

struct WaterSkiingCourse : Codable {
    let location: Coordinate
    let name: String
    let buoys: Array<Coordinate>
    let wakeCrosses: Array<Coordinate>
    let entryGate: Coordinate
    let exitGate: Coordinate
    
    init(
        location: Coordinate,
        name: String,
        buoys: Array<Coordinate>,
        wakeCrosses: Array<Coordinate>,
        entryGate: Coordinate,
        exitGate: Coordinate
    ) {
        self.location = location
        self.name = name
        self.buoys = buoys
        self.wakeCrosses = wakeCrosses
        self.entryGate = entryGate
        self.exitGate = exitGate
    }
}
