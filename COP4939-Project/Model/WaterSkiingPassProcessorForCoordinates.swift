//
//  DataProcessor.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation
import AVFoundation

class WaterSkiingPassProcessorForCoordinates : WaterSkiingPassProcessorProtocol {
    typealias P = Coordinate
    typealias C = WaterSkiingCourseBase<P>
    typealias R = TrackingRecord
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
    
    func process(course: WaterSkiingCourseBase<Coordinate>, records: Array<TrackingRecord>, video: Video<URL>) -> Pass<Coordinate, URL>? {
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
        
        passBuilder.setScore(calculateTotalScore(course: course, records: records))
        
        var crossedEntryGate: Bool = false
        
        logger.log(message: "Number of records: \(records.count)")
        
        var trimmedRecords = Array<TrackingRecord>()
        
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
            
            if inRange(point: record.location.coordinate, within: course.entryGatePosition, withRange: RANGE) {
                passBuilder.setEntryGate(GateBase(
                    maxSpeed: record.motion.speed,
                    maxRoll: record.motion.attitude.roll,
                    maxPitch: record.motion.attitude.pitch,
                    position: course.entryGatePosition,
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                )).setTimeOfRecording(record.timeOfRecordingInSeconds)
                
                crossedEntryGate = true
            }
            
            if inRange(point: record.location.coordinate, within: course.exitGatePosition, withRange: RANGE) {
                passBuilder.setExitGate(GateBase(
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    position: course.exitGatePosition,
                    timeOfRecordingInSeconds: record.timeOfRecordingInSeconds
                ))
            }
            
            if i < course.wakeCrossPositions.count && inRange(point: record.location.coordinate, within: course.wakeCrossPositions[i], withRange: RANGE) {
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
            
            if i < course.buoyPositions.count && inRange(point: record.location.coordinate, within: course.buoyPositions[i], withRange: RANGE) {
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
    
    private func calculateTotalScore(course: WaterSkiingCourseBase<Coordinate>, records: Array<TrackingRecord>) -> Int {
        var i = 0
        
        var score = 0
        
        for record in records {
            if i < course.buoyPositions.count && inRange(point: record.location.coordinate, within: course.buoyPositions[i], withRange: RANGE) {
                let skier = record.location.coordinate
                let buoy = course.buoyPositions[i]
                let entryGate = course.entryGatePosition
                let exitGate = course.exitGatePosition
                
                if i % 2 == 0 {
                    score += getBuoyScore(skier: skier, buoy: buoy, entryGate: entryGate, exitGate: exitGate, fromSide: .Right)
                } else {
                    score += getBuoyScore(skier: skier, buoy: buoy, entryGate: entryGate, exitGate: exitGate, fromSide: .Left)
                }
                
                i += 1
            }
        }
        
        return score
    }
    
    private func getBuoyScore(skier: Coordinate, buoy: Coordinate, entryGate: Coordinate, exitGate: Coordinate, fromSide: Side) -> Int {
        if fromSide == .Left && isLeftOf(skier: skier, buoy: buoy, entryGate: entryGate, exitGate: exitGate) ||
            fromSide == .Right && isRightOf(location: skier, buoy: buoy, entryGate: entryGate, exitGate: exitGate) {
            return 1
        }
        
        return 0
    }
    
    private func isLeftOf(skier: Coordinate, buoy: Coordinate, entryGate: Coordinate, exitGate: Coordinate) -> Bool {
        var bearingA = getBearingAngle(from: buoy, to: skier)
        let bearingB = getBearingAngle(from: entryGate, to: exitGate)
        
        let offset = Measurement<UnitAngle>(value: 90, unit: .degrees) - bearingB
        bearingA = bearingA - offset
        
        return bearingA > Measurement(value: 90, unit: .degrees) && bearingA < Measurement(value: 270, unit: .degrees)
    }
    
    private func isRightOf(location: Coordinate, buoy: Coordinate, entryGate: Coordinate, exitGate: Coordinate) -> Bool {
        var bearingA = getBearingAngle(from: buoy, to: location)
        let bearingB = getBearingAngle(from: entryGate, to: exitGate)
        
        let offset = Measurement<UnitAngle>(value: 90, unit: .degrees) - bearingB
        bearingA = bearingA - offset
        
        return !(bearingA > Measurement(value: 90, unit: .degrees) && bearingA < Measurement(value: 270, unit: .degrees))
    }
    
    private func getBearingAngle(from start: Coordinate, to end: Coordinate) -> Measurement<UnitAngle> {
        let startLat = start.latitude.converted(to: .radians)
        let endLat = end.latitude.converted(to: .radians)
        let startLon = start.longitude.converted(to: .radians)
        let endLon = end.longitude.converted(to: .radians)
        
        let dLon = endLon - startLon
        
        let y = sin(dLon.value) * cos(endLon.value)
        let x = cos(startLat.value) * sin(endLat.value) - sin(startLat.value) * cos(endLat.value) * cos(dLon.value)
        
        let c = atan2(y, x)
        
        var bearing = Measurement<UnitAngle>(value: c, unit: .radians)
        
        bearing = bearing.converted(to: .degrees) + Measurement(value: 360, unit: .degrees)
        
        return Measurement(value: bearing.value.truncatingRemainder(dividingBy: 360), unit: .degrees)
    }
    
    private func inRange(point: Coordinate, within locationWithRange: Coordinate, withRange: Measurement<UnitLength>) -> Bool {
        let distance = getHaversineDistance(from: point, to: locationWithRange)
        
        return distance <= withRange
    }
    
    private func getHaversineDistance(from start: Coordinate, to end: Coordinate) -> Measurement<UnitLength> {
        let r = 6371000.0
        
        let phi_1 = start.latitude.converted(to: .radians)
        let phi_2 = end.latitude.converted(to: .radians)
        let lambda_1 = start.longitude.converted(to: .radians)
        let lambda_2 = end.longitude.converted(to: .radians)
        
        let dPhi = phi_2 - phi_1
        let dLambda = lambda_2 - lambda_1
        
        let dPhiSin2 = pow(sin(dPhi.value / 2.0), 2)
        let dLambdaSin2 = pow(sin(dLambda.value / 2.0), 2)
        
        let a = dPhiSin2 + cos(phi_1.value) * cos(phi_2.value) * dLambdaSin2
        
        let d = 2 * r * asin(sqrt(a))
        
        return Measurement(value: d, unit: .meters)
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
    
    private enum Side {
        case Left
        case Right
    }
}
