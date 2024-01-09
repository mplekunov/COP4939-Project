//
//  WaterSkiingPassProcessorForVideo.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation
import AVFoundation

class WaterSkiingPassProcessorForVideo {
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
    
    func process(course: WaterSkiingCourseBase<Double>, totalScore: Int, records: Array<WatchTrackingRecord>, video: Video<URL>) async -> Pass<Double, URL>? {
        let passBuilder = PassBuilder<Double, URL>()
        
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
        
        passBuilder.setScore(totalScore)
        
        var crossedEntryGate: Bool = false
        
        var trimmedRecords = Array<WatchTrackingRecord>()
        
        for record in records {
            if record.timeOfRecordingInSeconds >= videoCreationDate {
                trimmedRecords.append(record)
            }
        }
        
        let alpha = 0.01
        
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
            
            if inRange(record.timeOfRecordingInSeconds, course.entryGatePosition + videoCreationDate, alpha: alpha) {
                passBuilder.setEntryGate(GateBase(
                    maxSpeed: record.motion.speed,
                    maxRoll: record.motion.attitude.roll,
                    maxPitch: record.motion.attitude.pitch,
                    position: course.entryGatePosition,
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                )).setTimeOfRecording(record.timeOfRecordingInSeconds)
                
                crossedEntryGate = true
            }
            
            if inRange(record.timeOfRecordingInSeconds, course.exitGatePosition + videoCreationDate, alpha: alpha) {
                passBuilder.setExitGate(GateBase(
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    position: course.exitGatePosition,
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                ))
            }
            
            if i < course.wakeCrossPositions.count && inRange(record.timeOfRecordingInSeconds, course.wakeCrossPositions[i] + videoCreationDate, alpha: alpha) {
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
            
            if i < course.buoyPositions.count && inRange(record.timeOfRecordingInSeconds, course.buoyPositions[i] + videoCreationDate, alpha: alpha) {
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
        
        do {
            guard let videoFile = try await trimVideo(
                startTime: startTime,
                endTime: endTime,
                video: video
            ) else {
                DispatchQueue.main.async {
                    self.error = "Could not process video file for water skiing pass"
                }
                return nil
            }
            
            passBuilder.setVideoFile(videoFile)
        } catch {
            DispatchQueue.main.async {
                self.error = "\(error)"
            }
        }
        
        return passBuilder.build()
    }
    
    private func inRange(_ first: Double, _ second: Double, alpha: Double) -> Bool {
        return (first - second) <= alpha
    }
    
    private func trimVideo(startTime: Double, endTime: Double, video: Video<URL>) async throws -> Video<URL>? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let documentsDirectory = documentsDirectory else { return nil }
        
        let creationDate = video.creationDate
        
        let startTime = abs(creationDate - startTime)
        let endTime = abs(creationDate - endTime)
        
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 1000)
        let endCMTime = CMTime(seconds: endTime, preferredTimescale: 1000)
        
        let movieOutputID = UUID()
        let movieOutputURL = documentsDirectory.appendingPathComponent("\(movieOutputID.uuidString).\(video.fileLocation.pathExtension)")
        
        if FileManager.default.fileExists(atPath: movieOutputURL.path()) {
            try FileManager.default.removeItem(at: movieOutputURL)
        }
        
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
