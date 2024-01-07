//
//  WaterSkiingSession.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

class PassBuilder<T, K> where T : Codable, K : Codable {
    public private(set) var score: Int?
    public private(set) var entryGate: GateBase<T>?
    public private(set) var exitGate: GateBase<T>?
    public private(set) var wakeCrosses: Array<WakeCrossBase<T>> = Array()
    public private(set) var buoys: Array<BuoyBase<T>> = Array()
    public private(set) var timeOfRecordingInSeconds: Double?
    public private(set) var videoFile: Video<K>?
    
    @discardableResult
    public func setScore(_ score: Int) -> PassBuilder{
        self.score = score
        return self
    }
    
    @discardableResult
    public func setEntryGate(_ gate: GateBase<T>) -> PassBuilder {
        self.entryGate = gate
        return self
    }
    
    @discardableResult
    public func setExitGate(_ gate: GateBase<T>) -> PassBuilder {
        self.exitGate = gate
        return self
    }
    
    @discardableResult
    public func addWakeCross(_ stats: WakeCrossBase<T>) -> PassBuilder {
        self.wakeCrosses.append(stats)
        return self
    }
    
    @discardableResult
    public func setWakeCrosses(_ stats: Array<WakeCrossBase<T>>) -> PassBuilder {
        self.wakeCrosses = stats
        return self
    }
    
    @discardableResult
    public func addBuoy(_ stats: BuoyBase<T>) -> PassBuilder {
        self.buoys.append(stats)
        return self
    }
    
    @discardableResult
    public func setBuoys(_ stats: Array<BuoyBase<T>>) -> PassBuilder {
        self.buoys = stats
        return self
    }
    
    @discardableResult
    public func setTimeOfRecording(_ timeInSeconds: Double) -> PassBuilder {
        self.timeOfRecordingInSeconds = timeInSeconds
        return self
    }
    
    @discardableResult
    public func setVideoFile(_ videoFile: Video<K>) -> PassBuilder {
        self.videoFile = videoFile
        return self
    }
    
    public func build() -> Pass<T, K>? {
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

struct Pass<T, K> : Codable where T : Codable, K : Codable {
    public let score: Int
    public let entryGate: GateBase<T>
    public let exitGate: GateBase<T>
    public let wakeCrosses: Array<WakeCrossBase<T>>
    public let buoys: Array<BuoyBase<T>>
    public let timeOfRecordingInSeconds: Double
    public let videoFile: Video<K>?
}
