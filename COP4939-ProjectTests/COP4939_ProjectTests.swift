//
//  COP4939_ProjectTests.swift
//  COP4939-ProjectTests
//
//  Created by Mikhail Plekunov on 11/27/23.
//

import XCTest
@testable import COP4939_Project

final class COP4939_ProjectTests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
    
    /**
            Test Course (degrees)
     
         1.5, 6.5 -> exit Gate
     
     1, 6 - (2, 6) -> b6
     
         1.5, 5.5 -> w6
     
     (1, 5) - 2, 5 -> b5
         
        1.5, 4.5 -> w5
     
     1, 4 - (2, 4) -> b4
         
        1.5, 3.5 -> w4
     
     (1, 3) - 2, 3 -> b3
     
        1.5, 2.5 -> w3
     
     1, 2 - (2, 2) -> b2
     
        1.5, 1.5 -> w2
        
     (1, 1) - 2, 1 -> b1
         
        1.5, 0.5 -> w1
          
        1.5, 0 -> entry Gate
     */
    
    private func getCoordinate(lat: Double, lon: Double) -> Coordinate {
        return Coordinate(latitude: Measurement(value: lat, unit: .degrees), longitude: Measurement(value: lon, unit: .degrees))
    }
    
    func testExample() throws {
        let length: Measurement<UnitLength> = Measurement(value: 1, unit: .meters)
        let angle: Measurement<UnitAngle> = Measurement(value: 1, unit: .degrees)
        
        let processor = WaterSkiingPassProcessor(
            user: WaterSkier(
                user: User(
                    name: "Michael",
                    dateOfBirth: Date(),
                    username: "Test",
                    password: "Test"
                ),
                ageGroup: .Group_1,
                ski: Ski(brand: "a", style: "b", length: length, bindingType: "c"),
                fin: Fin(length: length, depth: length, dft: length, wingAngle: angle, bladeThickness: length)
            ),
            boat: Boat(name: "A", driver: BoatDriver(name: "A")),
            course: WaterSkiingCourse(
                location: Coordinate(latitude: Measurement(value: 0, unit: .degrees), longitude: Measurement(value: 0, unit: .degrees)),
                name: "Test",
                buoys: Array([
                    getCoordinate(lat: 2, lon: 1),
                    getCoordinate(lat: 1, lon: 2),
                    getCoordinate(lat: 2, lon: 3),
                    getCoordinate(lat: 1, lon: 4),
                    getCoordinate(lat: 2, lon: 5),
                    getCoordinate(lat: 1, lon: 6)
                ]),
                wakeCrosses: Array([
                    getCoordinate(lat: 1.5, lon: 0.5),
                    getCoordinate(lat: 1.5, lon: 1.5),
                    getCoordinate(lat: 1.5, lon: 2.5),
                    getCoordinate(lat: 1.5, lon: 3.5),
                    getCoordinate(lat: 1.5, lon: 4.5),
                    getCoordinate(lat: 1.5, lon: 5.5)
                ]),
                entryGate: getCoordinate(lat: 1.5, lon: 0),
                exitGate: getCoordinate(lat: 1.5, lon: 6.5)
            )
        )
        
        let trackingRecords = Array([
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 0)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 0.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 2.1, lon: 1)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 1.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 0.9, lon: 2)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 2.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 2.1, lon: 3)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 3.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 0.9, lon: 4)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 4.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 2.1, lon: 5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 5.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 0.9, lon: 6)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 6.5))
        ])
        
        let result = processor.processPass(records: trackingRecords, videoId: UUID())
        
        print(result)
        
        XCTAssertNil(result)
    }

    private func generateTrackingRecord(coordinate: Coordinate) -> TrackingRecord {
        let acceleration: Measurement<UnitAcceleration> = Measurement(value: 0, unit: .metersPerSecondSquared)
        let angle: Measurement<UnitAngle> = Measurement(value: 1, unit: .degrees)
        let speed: Measurement<UnitSpeed> = Measurement(value: 0, unit: .metersPerSecond)
        
        let motionRecord = MotionRecord(
            attitude: Attitude(roll: angle, yaw: angle, pitch: angle),
            acceleration: Unit3D(x: acceleration, y: acceleration, z: acceleration),
            gForce: Unit3D(x: acceleration, y: acceleration, z: acceleration)
        )
        
        return TrackingRecord(
            location: LocationRecord(speed: speed, coordinate: coordinate, directionInDegrees: angle),
            motion: motionRecord,
            timeStamp: Date().timeIntervalSince1970
        )
    }
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
