//
//  WaterSkiingSession.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

class PassBuilder {
    public private(set) var score: Int = 0
    public private(set) var entryGate: Gate = Gate(
        location: Coordinate(latitude: Measurement(value: 0, unit: .degrees), longitude: Measurement(value: 0, unit: .degrees)),
        maxSpeed: Measurement(value: 0, unit: .metersPerSecond),
        maxRoll: Measurement(value: 0, unit: .degrees),
        maxPitch: Measurement(value: 0, unit: .degrees),
        timeWhenPassed: 0
    )
    public private(set) var exitGate: Gate = Gate(
        location: Coordinate(latitude: Measurement(value: 0, unit: .degrees), longitude: Measurement(value: 0, unit: .degrees)),
        maxSpeed: Measurement(value: 0, unit: .metersPerSecond),
        maxRoll: Measurement(value: 0, unit: .degrees),
        maxPitch: Measurement(value: 0, unit: .degrees),
        timeWhenPassed: 0
    )
    public private(set) var wakeCrosses: Array<WakeCross> = Array()
    public private(set) var buoys: Array<Buoy> = Array()
    public private(set) var timeStamp: Double = Date().timeIntervalSince1970
    public private(set) var videoId: UUID = UUID()
    
    @discardableResult
    public func setScore(_ score: Int) -> PassBuilder{
        self.score = score
        return self
    }
    
    @discardableResult
    public func setEntryGate(_ gate: Gate) -> PassBuilder {
        self.entryGate = gate
        return self
    }
    
    @discardableResult
    public func setExitGate(_ gate: Gate) -> PassBuilder {
        self.exitGate = gate
        return self
    }
    
    @discardableResult
    public func addWakeCross(_ stats: WakeCross) -> PassBuilder {
        self.wakeCrosses.append(stats)
        return self
    }
    
    @discardableResult
    public func setWakeCrosses(_ stats: Array<WakeCross>) -> PassBuilder {
        self.wakeCrosses = stats
        return self
    }
    
    @discardableResult
    public func addBuoy(_ stats: Buoy) -> PassBuilder {
        self.buoys.append(stats)
        return self
    }
    
    @discardableResult
    public func setBuoys(_ stats: Array<Buoy>) -> PassBuilder {
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
    public let entryGate: Gate
    public let exitGate: Gate
    public let wakeCrosses: Array<WakeCross>
    public let buoys: Array<Buoy>
    public let timeStamp: Double
    public let videoId: UUID
}
