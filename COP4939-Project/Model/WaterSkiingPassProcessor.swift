//
//  DataProcessor.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation
import AVFoundation

class WaterSkiingPassProcessor {
    private var logger: LoggerService
    
    private let videoManager = VideoManager()
    
    private let NUM_OF_BUOYS = 6
    
    private let RANGE = Measurement<UnitLength>(value: 1.0, unit: .meters)
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
    }
    
    func processPass(course: WaterSkiingCourse, records: Array<TrackingRecord>, videoFile: VideoFile) -> Pass? {
        let passBuilder = PassBuilder()
        
        let videoCreationDate = videoFile.creationDate
        
        if records.isEmpty {
            logger.error(message: "Data array cannot be empty")
            return nil
        }
        
        if course.buoys.count != course.wakeCrosses.count && course.wakeCrosses.count != NUM_OF_BUOYS {
            logger.error(message: "The number of buoys/wake crosses is incorrect")
            return nil
        }
        
        var maxSpeed = Measurement<UnitSpeed>(value: 0.0, unit: records.first!.location.speed.unit)
        var maxRoll = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.roll.unit)
        var maxPitch = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.pitch.unit)
        var maxGForce = Measurement<UnitAcceleration>(value: 0.0, unit: records.first!.motion.gForce.x.unit)
        var maxAcceleration = Measurement<UnitAcceleration>(value: 0.0, unit: records.first!.motion.acceleration.x.unit)
        var maxAngle = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.yaw.unit)
        
        var i = 0
        
        passBuilder.setScore(calculateTotalScore(course: course, records: records))
        
        var crossedEntryGate: Bool = false
        
        for record in records {
            if crossedEntryGate {
                maxSpeed = max(record.location.speed, maxSpeed)
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
            
            if inRange(point: record.location.coordinate, within: course.entryGate, withRange: RANGE) {
                passBuilder.setEntryGate(Gate(
                    location: course.entryGate,
                    maxSpeed: record.location.speed,
                    maxRoll: record.motion.attitude.roll,
                    maxPitch: record.motion.attitude.pitch,
                    timeOfRecordingInSeconds: abs(record.timeOfRecordingInSeconds - videoCreationDate))
                ).setTimeOfRecording(record.timeOfRecordingInSeconds)
                
                crossedEntryGate = true
            }
            
            if inRange(point: record.location.coordinate, within: course.exitGate, withRange: RANGE) {
                passBuilder.setExitGate(Gate(
                    location: course.exitGate,
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    timeOfRecordingInSeconds: abs(record.timeOfRecordingInSeconds - videoCreationDate))
                )
            }
            
            if i < course.wakeCrosses.count && inRange(point: record.location.coordinate, within: course.wakeCrosses[i], withRange: RANGE) {
                passBuilder.addWakeCross(WakeCross(
                    location: course.wakeCrosses[i],
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    maxAngle: maxAngle,
                    maxGForce: maxGForce,
                    maxAcceleration: maxAcceleration,
                    timeOfRecordingInSeconds: abs(record.timeOfRecordingInSeconds - videoCreationDate))
                )
            }
            
            if i < course.buoys.count && inRange(point: record.location.coordinate, within: course.buoys[i], withRange: RANGE) {
                passBuilder.addBuoy(Buoy(
                    location: course.buoys[i],
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    timeOfRecordingInSeconds: abs(record.timeOfRecordingInSeconds - videoCreationDate))
                )
                
                i += 1
            }
        }
        
        Task {
            let videoFile = await processVideo(
                startTime: passBuilder.entryGate.timeOfRecordingInSeconds,
                endTime: passBuilder.exitGate.timeOfRecordingInSeconds,
                videoFile: videoFile
            )
            
            passBuilder.setVideoFile(videoFile)
        }
        
        return passBuilder.build()
    }
    
    private func processVideo(startTime: Double, endTime: Double, videoFile: VideoFile) async -> VideoFile {
        let asset = AVAsset(url: videoFile.url)
        let composition = AVVideoComposition()
        
        let creationDate = videoFile.creationDate
        
        let startTime = abs(creationDate - startTime)
        let endTime = abs(creationDate - endTime)
        
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 100)
        let endCMTime = CMTime(seconds: endTime, preferredTimescale: 100)
        
        await videoManager.export(asset, to: videoFile.url, startTime: startCMTime, endTime: endCMTime, composition: composition)
        
        return videoFile
        
    }
    
    private func calculateTotalScore(course: WaterSkiingCourse, records: Array<TrackingRecord>) -> Int {
        var i = 0
        
        var score = 0
        
        for record in records {
            if i < course.buoys.count && inRange(point: record.location.coordinate, within: course.buoys[i], withRange: RANGE) {
                let skier = record.location.coordinate
                let buoy = course.buoys[i]
                let entryGate = course.entryGate
                let exitGate = course.exitGate
                
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
        let earthRadius = 6371.0
        
        let firstLat = start.latitude.converted(to: .radians)
        let secondLat = end.latitude.converted(to: .radians)
        let firstLon = start.longitude.converted(to: .radians)
        let secondLon = end.longitude.converted(to: .radians)
        
        let dLat = secondLat - firstLat
        let dLon = secondLon - firstLon
        
        let haversineLat = sin(dLat.value / 2.0) * sin(dLat.value / 2.0)
        let haversineLon = sin(dLon.value / 2.0) * sin(dLon.value / 2.0)
        
        let a = haversineLat + cos(firstLat.value) * cos(secondLat.value) * haversineLon
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return Measurement(value: c * earthRadius, unit: .kilometers)
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
