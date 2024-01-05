//
//  COP4939_ProjectApp.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 11/27/23.
//

import SwiftUI
import Foundation
import AVFoundation

@main
struct COP4939_ProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


//private func getCoordinate(lat: Double, lon: Double) -> Coordinate {
//    return Coordinate(latitude: Measurement(value: lat, unit: .degrees), longitude: Measurement(value: lon, unit: .degrees))
//}
//
//func generateTestPass() -> Pass {
//    let processor = WaterSkiingPassProcessor()
//    
//    let trackingRecords = Array([
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 0), timeStamp: 0),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 0.5), timeStamp: 2),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 1), timeStamp: 12),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 1.5), timeStamp: 15),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 2), timeStamp: 19),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 2.5), timeStamp: 23),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 3), timeStamp: 29),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 3.5), timeStamp: 35),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 4), timeStamp: 42),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 4.5), timeStamp: 45),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 5), timeStamp: 80),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 5.5), timeStamp: 91),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 6), timeStamp: 95),
//        generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 6.5), timeStamp: 100)
//    ])
//    
//    return processor.processPass(
//        course: WaterSkiingCourse(
//            location: Coordinate(latitude: Measurement(value: 0, unit: .degrees), longitude: Measurement(value: 0, unit: .degrees)),
//            name: "Test",
//            buoys: Array([
//                getCoordinate(lat: 2, lon: 1),
//                getCoordinate(lat: 1, lon: 2),
//                getCoordinate(lat: 2, lon: 3),
//                getCoordinate(lat: 1, lon: 4),
//                getCoordinate(lat: 2, lon: 5),
//                getCoordinate(lat: 1, lon: 6)
//            ]),
//            wakeCrosses: Array([
//                getCoordinate(lat: 1.5, lon: 0.5),
//                getCoordinate(lat: 1.5, lon: 1.5),
//                getCoordinate(lat: 1.5, lon: 2.5),
//                getCoordinate(lat: 1.5, lon: 3.5),
//                getCoordinate(lat: 1.5, lon: 4.5),
//                getCoordinate(lat: 1.5, lon: 5.5)
//            ]),
//            entryGate: getCoordinate(lat: 1.5, lon: 0),
//            exitGate: getCoordinate(lat: 1.5, lon: 6.5)
//        ),
//        records: trackingRecords,
//        videoFile: VideoFile(id: UUID(), url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)
//    )
//}
//
//private func generateTrackingRecord(coordinate: Coordinate, timeStamp: Double) -> TrackingRecord {
//    let speed: Measurement<UnitSpeed> = Measurement(value: Double.random(in: 0...30), unit: .metersPerSecond)
//    
//    let motionRecord = MotionRecord(
//        attitude: Attitude(roll: getRandomAngle(), yaw: getRandomAngle(), pitch: getRandomAngle()),
//        acceleration: Unit3D(x: getRandomAcceleration(), y: getRandomAcceleration(), z: getRandomAcceleration()),
//        gForce: Unit3D(x: getRandomAcceleration(), y: getRandomAcceleration(), z: getRandomAcceleration())
//    )
//    
//    return TrackingRecord(
//        location: LocationRecord(speed: speed, coordinate: coordinate),
//        motion: motionRecord,
//        timeStamp: timeStamp
//    )
//}
//
//private func getRandomAcceleration() -> Measurement<UnitAcceleration> {
//    return Measurement(value: Double.random(in: 0...40), unit: .metersPerSecondSquared)
//}
//
//private func getRandomAngle() -> Measurement<UnitAngle> {
//    return Measurement(value: Double.random(in: 0...30), unit: .degrees)
//}
