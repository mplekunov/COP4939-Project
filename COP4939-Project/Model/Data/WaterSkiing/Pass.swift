//
//  WaterSkiingSession.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

class PassBuilder {
    public private(set) var score: Int?
    public private(set) var entryGate: Gate?
    public private(set) var exitGate: Gate?
    public private(set) var wakeCrosses: Array<WakeCross> = Array()
    public private(set) var buoys: Array<Buoy> = Array()
    public private(set) var timeOfRecordingInSeconds: Double?
    public private(set) var videoFile: VideoFile?
    
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
    public func setTimeOfRecording(_ timeInSeconds: Double) -> PassBuilder {
        self.timeOfRecordingInSeconds = timeInSeconds
        return self
    }
    
    @discardableResult
    public func setVideoFile(_ videoFile: VideoFile) -> PassBuilder {
        self.videoFile = videoFile
        return self
    }
    
    public func build() -> Pass? {
        guard let score = score,
              let entryGate = entryGate,
              let exitGate = exitGate,
              let timeOfRecordingInSeconds = timeOfRecordingInSeconds,
              let videoFile = videoFile,
              !wakeCrosses.isEmpty,
              !buoys.isEmpty 
        else { return nil }
        
        return Pass(
            score: score,
            entryGate: entryGate,
            exitGate: exitGate,
            wakeCrosses: wakeCrosses,
            buoys: buoys,
            timeOfRecordingInSeconds: timeOfRecordingInSeconds,
            videoFile: videoFile
        )
    }
}

struct Pass {
    public let score: Int
    public let entryGate: Gate
    public let exitGate: Gate
    public let wakeCrosses: Array<WakeCross>
    public let buoys: Array<Buoy>
    public let timeOfRecordingInSeconds: Double
    public let videoFile: VideoFile?
}
