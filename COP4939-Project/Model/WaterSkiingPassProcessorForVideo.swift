//
//  WaterSkiingPassProcessorForVideo.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation
import AVFoundation

class WaterSkiingPassProcessorForVideo : WaterSkiingPassProcessorProtocol {
    typealias P = Double
    typealias C = WaterSkiingCourseFromVideo
    typealias R = WatchTrackingRecord
    typealias V = URL
    
    private var logger: LoggerService
    
    private let videoManager = VideoManager()
    
    @Published public private(set) var error: String?
    
    private let NUM_OF_BUOYS = 6
    
    private let RANGE = Measurement<UnitLength>(value: 1.0, unit: .meters)
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        videoManager.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
    }
    
    func process(course: C, records: Array<R>, video: Video<V>) -> Pass<P, V>? {
        let passBuilder = PassBuilder<P, V>()
        
        let videoCreationDate = video.creationDate
        
        if records.isEmpty {
            error = "Data array cannot be empty"
            return nil
        }
        
        if course.buoyPositions.count != course.wakeCrossPositions.count && course.wakeCrossPositions.count != NUM_OF_BUOYS {
            error = "The number of buoys/wake crosses is incorrect"
            return nil
        }
        
        var maxSpeed = Measurement<UnitSpeed>(value: 0.0, unit: records.first!.motion.speed.unit)
        var maxRoll = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.roll.unit)
        var maxPitch = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.pitch.unit)
        var maxGForce = Measurement<UnitAcceleration>(value: 0.0, unit: records.first!.motion.gForce.x.unit)
        var maxAcceleration = Measurement<UnitAcceleration>(value: 0.0, unit: records.first!.motion.acceleration.x.unit)
        var maxAngle = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.yaw.unit)
        
        var i = 0
        
        passBuilder.setScore(course.totalScore)
        
        var crossedEntryGate: Bool = false
        
        logger.log(message: "Number of records: \(records.count)")
        
        var trimmedRecords = Array<R>()
        
        for record in records {
            if record.timeOfRecordingInSeconds >= videoCreationDate {
                trimmedRecords.append(record)
            }
        }
        
        for record in trimmedRecords {
            if crossedEntryGate {
                maxSpeed = max(record.motion.speed, maxSpeed)
                maxPitch = max(record.motion.attitude.pitch, maxPitch)
                maxRoll = max(record.motion.attitude.roll, maxRoll)
                maxAngle = max(record.motion.attitude.yaw, maxAngle)
                maxGForce = max(
                    getTotalFromPythagorean(x: record.motion.gForce.x, y: record.motion.gForce.y, z: record.motion.gForce.z),
                    maxGForce
                )
                maxAcceleration = max(
                    getTotalFromPythagorean(x: record.motion.acceleration.x, y: record.motion.acceleration.y, z: record.motion.acceleration.z),
                    maxAcceleration
                )
            }
            
            if record.timeOfRecordingInSeconds == course.entryGatePosition {
                passBuilder.setEntryGate(GateBase(
                    maxSpeed: record.motion.speed,
                    maxRoll: record.motion.attitude.roll,
                    maxPitch: record.motion.attitude.pitch,
                    position: course.entryGatePosition,
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                )).setTimeOfRecording(record.timeOfRecordingInSeconds)
                
                crossedEntryGate = true
            }
            
            if record.timeOfRecordingInSeconds == course.exitGatePosition {
                passBuilder.setExitGate(GateBase(
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    position: course.exitGatePosition,
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                ))
            }
            
            if i < course.wakeCrossPositions.count && record.timeOfRecordingInSeconds == course.wakeCrossPositions[i] {
                passBuilder.addWakeCross(WakeCrossBase(
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    maxAngle: maxAngle,
                    maxGForce: maxGForce,
                    maxAcceleration: maxAcceleration,
                    position: course.wakeCrossPositions[i],
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                ))
            }
            
            if i < course.buoyPositions.count && record.timeOfRecordingInSeconds == course.buoyPositions[i] {
                passBuilder.addBuoy(BuoyBase(
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    position: course.buoyPositions[i],
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                ))
                
                i += 1
            }
        }
        
        guard let startTime = passBuilder.entryGate?.timeOfRecordingInSeconds,
              let endTime = passBuilder.exitGate?.timeOfRecordingInSeconds else {
            return nil
        }
        
        Task {
            do {
                guard let videoFile = try await trimVideo(
                    startTime: startTime,
                    endTime: endTime,
                    video: video
                ) else {
                    error = "Could not process video file for water skiing pass"
                    return
                }
                
                passBuilder.setVideoFile(videoFile)
            } catch {
                self.error = "\(error)"
            }
        }
        
        return passBuilder.build()
    }
    
    private func trimVideo(startTime: Double, endTime: Double, video: Video<V>) async throws -> Video<V>? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let documentsDirectory = documentsDirectory else { return nil }
        
        let creationDate = video.creationDate
        
        let startTime = abs(creationDate - startTime)
        let endTime = abs(creationDate - endTime)
        
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 1000)
        let endCMTime = CMTime(seconds: endTime, preferredTimescale: 1000)
        
        let movieOutputID = UUID()
        let movieOutputURL = documentsDirectory.appendingPathComponent("\(movieOutputID.uuidString).\(video.fileLocation.pathExtension)")
        
        try FileManager.default.removeItem(at: movieOutputURL)
        
        try await videoManager.trimVideo(source: video.fileLocation, to: movieOutputURL, startTime: startCMTime, endTime: endCMTime)
        
        return Video(id: movieOutputID, creationDate: video.creationDate, fileLocation: movieOutputURL)
    }
    
    private func getTotalFromPythagorean<T: Unit>(x: Measurement<T>, y: Measurement<T>, z: Measurement<T>) -> Measurement<T> {
        let xValue = x.value
        let yValue = y.value
        let zValue = z.value
        
        if x.unit != y.unit || y.unit != z.unit {
            logger.error(message: "Units are not the same.")
        }
        
        let totalValue = sqrt(xValue * xValue + yValue * yValue + zValue * zValue)
        
        return Measurement(value: totalValue, unit: x.unit)
    }
}
