//
//  WaterSkiingSession.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct WaterSkiingSession {
    let id: UUID
    let boat: Boat
    let user: WaterSkier
    let location: LocationRecord
    let date: Double
    let passes: Array<Pass>
    
    init(id: UUID, boat: Boat, user: WaterSkier, location: LocationRecord, date: Double, passes: Array<Pass>) {
        self.id = id
        self.boat = boat
        self.user = user
        self.location = location
        self.date = date
        self.passes = passes
    }
}
