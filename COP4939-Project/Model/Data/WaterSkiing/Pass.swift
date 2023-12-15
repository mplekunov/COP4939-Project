//
//  WaterSkiingSession.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

class PassBuilder {
    public private(set) var score: Int = 0
    public private(set) var startSpeed: Measurement<UnitSpeed> = Measurement(value: 0, unit: .metersPerSecond)
    public private(set) var entryGate: Stats = Stats(
        maxSpeed: Measurement(value: 0, unit: .metersPerSecond),
        maxRoll: Measurement(value: 0, unit: .degrees),
        maxPitch: Measurement(value: 0, unit: .degrees)
    )
    public private(set) var exitGate: Stats = Stats(
        maxSpeed: Measurement(value: 0, unit: .metersPerSecond),
        maxRoll: Measurement(value: 0, unit: .degrees),
        maxPitch: Measurement(value: 0, unit: .degrees)
    )
    public private(set) var wakeCrosses: Array<Stats> = Array()
    public private(set) var buoys: Array<Stats> = Array()
    public private(set) var timeStamp: Double = Date().timeIntervalSince1970
    public private(set) var videoId: UUID = UUID()
    
    @discardableResult
    public func setScore(_ score: Int) -> PassBuilder{
        self.score = score
        return self
    }
    
    @discardableResult
    public func setStartSpeed(_ speed: Measurement<UnitSpeed>) -> PassBuilder {
        self.startSpeed = speed
        return self
    }
    
    @discardableResult
    public func setEntryGate(_ gate: Stats) -> PassBuilder {
        self.entryGate = gate
        return self
    }
    
    @discardableResult
    public func setExitGate(_ gate: Stats) -> PassBuilder {
        self.exitGate = gate
        return self
    }
    
    @discardableResult
    public func addWakeCross(_ stats: Stats) -> PassBuilder {
        self.wakeCrosses.append(stats)
        return self
    }
    
    @discardableResult
    public func setWakeCrosses(_ stats: Array<Stats>) -> PassBuilder {
        self.wakeCrosses = stats
        return self
    }
    
    @discardableResult
    public func addBuoy(_ stats: Stats) -> PassBuilder {
        self.buoys.append(stats)
        return self
    }
    
    @discardableResult
    public func setBuoys(_ stats: Array<Stats>) -> PassBuilder {
        self.buoys = stats
        return self
    }
    
    @discardableResult
    public func setTimeStamp(_ time: Double) -> PassBuilder {
        self.timeStamp = time
        return self
    }
    
    @discardableResult 
    public func setVideoId(_ id: UUID) -> PassBuilder {
        self.videoId = id
        return self
    }
    
    public func build() -> Pass {
        return Pass(
            score: score,
            startSpeed: startSpeed,
            entryGate: entryGate,
            exitGate: exitGate,
            wakeCrosses: wakeCrosses,
            buoys: buoys,
            timeStamp: timeStamp,
            videoId: videoId
        )
    }
}

struct Pass {
    public let score: Int
    public let startSpeed: Measurement<UnitSpeed>
    public let entryGate: Stats
    public let exitGate: Stats
    public let wakeCrosses: Array<Stats>
    public let buoys: Array<Stats>
    public let timeStamp: Double
    public let videoId: UUID
}
