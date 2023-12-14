//
//  DataProcessor.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/11/23.
//

import Foundation

class WaterSkiingProcessor : ObservableObject {
    private var logger: LoggerService
    
    private let boat: Boat
    private let user: WaterSkier
    private let NUM_OF_BUOYS = 6
    private let course: WaterSkiingCourse
    
    init(user: WaterSkier, boat: Boat, course: WaterSkiingCourse) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        self.boat = boat
        self.user = user
        self.course = course
    }
    
    func processPass(records: Array<TrackingRecord>, videoId: UUID) -> Pass? {
        if records.isEmpty {
            logger.error(message: "Data array cannot be empty")
            return nil
        }
        
        var maxSpeed = Measurement<UnitSpeed>(value: 0.0, unit: records.first!.location.speed.unit)
        var maxRoll = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.roll.unit)
        var maxPitch = Measurement<UnitAngle>(value: 0.0, unit: records.first!.motion.attitude.pitch.unit)
        var maxGForce = Measurement<UnitAcceleration>(value: 0.0, unit: records.first!.motion.gForce.x.unit)
        var maxAcceleration = Measurement<UnitAcceleration>(value: 0.0, unit: records.first!.motion.acceleration.x.unit)
        var maxAngle = Measurement<UnitAngle>(value: 0.0, unit: .degrees)
        
        var i = 0
        
        let range = Measurement<UnitLength>(value: 1.0, unit: .meters)
        
        var startSpeed = Measurement<UnitSpeed>(value: 0.0, unit: records.first!.location.speed.unit)
        var timeStamp = 0.0
        var entryGate: Stats? = nil
        var exitGate: Stats? = nil
        var buoys = Array<Stats>()
        var wakeCrosses = Array<Stats>()
        var score = 0
        
        for record in records {
            maxSpeed = max(record.location.speed, maxSpeed)
            maxPitch = max(record.motion.attitude.pitch, maxPitch)
            maxRoll = max(record.motion.attitude.roll, maxRoll)
            
            maxGForce = max(
                getTotalFromPythagorean(x: record.motion.gForce.x, y: record.motion.gForce.y, z: record.motion.gForce.z), 
                maxGForce
            )
            maxAcceleration = max(
                getTotalFromPythagorean(x: record.motion.acceleration.x, y: record.motion.acceleration.y, z: record.motion.acceleration.z), 
                maxAcceleration
            )

            if inRangeWithApproximation(location: record.location.coordinate, locationWithRange: course.entryGate, range: range) {
                entryGate = Stats(maxSpeed: maxSpeed, maxRoll: maxRoll, maxPitch: maxPitch)
                startSpeed = record.location.speed
                timeStamp = record.timeStamp
            }
            
            if inRangeWithApproximation(location: record.location.coordinate, locationWithRange: course.exitGate, range: range) {
                exitGate = Stats(maxSpeed: maxSpeed, maxRoll: maxRoll, maxPitch: maxPitch)
            }
            
            if i < course.wakeCrosses.count && inRangeWithApproximation(location: record.location.coordinate, locationWithRange: course.wakeCrosses[i], range: range) {
                wakeCrosses.append(Stats(
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch,
                    maxAngle: maxAngle,
                    maxGForce: maxGForce,
                    maxAcceleration: maxAcceleration
                ))
            }
            
            if i < course.buoys.count && inRangeWithApproximation(location: record.location.coordinate, locationWithRange: course.buoys[i], range: range) {
                buoys.append(Stats(
                    maxSpeed: maxSpeed,
                    maxRoll: maxRoll,
                    maxPitch: maxPitch
                ))
                
                i += 1
            }
        }
        
        guard entryGate != nil && exitGate != nil else {
            return nil
        }
        
        i = 0
        
        for record in records {
            if i < course.buoys.count && inRangeWithApproximation(location: record.location.coordinate, locationWithRange: course.buoys[i], range: range) {
                if i % 2 == 0 {
                    logger.log(message: "Right")
                    score += getBuoyScore(location: record.location.coordinate, buoy: course.buoys[i], startGate: course.entryGate, endGate: course.exitGate, fromSide: .Right)
                } else {
                    logger.log(message: "Left")
                    score += getBuoyScore(location: record.location.coordinate, buoy: course.buoys[i], startGate: course.entryGate, endGate: course.exitGate, fromSide: .Left)
                }
                
                i += 1
            }
        }
        
        return Pass(
            score: score,
            startSpeed: startSpeed,
            entryGate: entryGate!,
            exitGate: exitGate!,
            wakeCrosses: wakeCrosses,
            buoys: buoys,
            timeStamp: timeStamp,
            videoId: videoId
        )
    }
    
    private func getBuoyScore(location: Coordinate, buoy: Coordinate, startGate: Coordinate, endGate: Coordinate, fromSide: Side) -> Int {
        if fromSide == .Left && isLeftOf(location: location, buoy: buoy, startGate: startGate, endGate: endGate) ||
            fromSide == .Right && isRightOf(location: location, buoy: buoy, startGate: startGate, endGate: endGate) {
            return 1
        }
        
        return 0
    }
    
    private func isLeftOf(location: Coordinate, buoy: Coordinate, startGate: Coordinate, endGate: Coordinate) -> Bool {
        var bearingA = getBearingAngle(from: buoy, to: location)
        let bearingB = getBearingAngle(from: startGate, to: endGate)
        
        let offset = Measurement<UnitAngle>(value: 90, unit: .degrees) - bearingB
        bearingA = bearingA - offset
        
        return bearingA > Measurement(value: 90, unit: .degrees) && bearingA < Measurement(value: 270, unit: .degrees)
    }
    
    private func isRightOf(location: Coordinate, buoy: Coordinate, startGate: Coordinate, endGate: Coordinate) -> Bool {
        var bearingA = getBearingAngle(from: buoy, to: location)
        let bearingB = getBearingAngle(from: startGate, to: endGate)
        
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
    
    private func inRangeWithApproximation(location: Coordinate, locationWithRange: Coordinate, range: Measurement<UnitLength>) -> Bool {
        let distance = getHaversineDistance(from: location, to: locationWithRange)
        
        return distance <= range
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
    
    enum Side {
        case Left
        case Right
    }
}
