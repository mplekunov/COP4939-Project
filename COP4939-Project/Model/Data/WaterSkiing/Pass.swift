//
//  WaterSkiingSession.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct Pass {
    let score: Int
    let startSpeed: Measurement<UnitSpeed>
    let entryGate: Stats
    let exitGate: Stats
    let wakeCrosses: Array<Stats>
    let buoys: Array<Stats>
    let timeStamp: Double
    let videoId: UUID
    
    init(
        score: Int,
        startSpeed: Measurement<UnitSpeed>,
        entryGate: Stats,
        exitGate: Stats,
        wakeCrosses: Array<Stats>,
        buoys: Array<Stats>,
        timeStamp: Double,
        videoId: UUID
    ) {
        self.score = score
        self.startSpeed = startSpeed
        self.entryGate = entryGate
        self.exitGate = exitGate
        self.wakeCrosses = wakeCrosses
        self.buoys = buoys
        self.timeStamp = timeStamp
        self.videoId = videoId
    }
}
