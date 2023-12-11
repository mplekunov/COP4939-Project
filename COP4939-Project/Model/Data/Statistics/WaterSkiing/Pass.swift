//
//  WaterSkiingSession.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

struct Pass {
    let startSpeed: Double
    let score: Double
    let wakeCrosses: Array<WakeCross>
    let buoys: Array<Buoy>
    let timeStamp: Double
    let videoId: UUID
    
    init(startSpeed: Double, score: Double, wakeCrosses: Array<WakeCross>, buoys: Array<Buoy>, timeStamp: Double, videoId: UUID) {
        self.startSpeed = startSpeed
        self.score = score
        self.wakeCrosses = wakeCrosses
        self.buoys = buoys
        self.timeStamp = timeStamp
        self.videoId = videoId
    }
}
