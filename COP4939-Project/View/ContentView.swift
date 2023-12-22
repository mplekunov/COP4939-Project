//
//  ContentView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var dataReceiverViewModel: DataReceiverViewModel = DataReceiverViewModel()
    @StateObject var waterSkiingCourseViewModel: WaterSkiingCourseViewModel = WaterSkiingCourseViewModel()
    @StateObject var dataSenderViewModel: DataSenderViewModel = DataSenderViewModel()
    @StateObject var cameraViewModel = CameraViewModel()
    
    @State private var showCourseSetupView: Bool = false
    @State private var showSessionRecordingView: Bool = false
    @State private var showSessionResultView: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            if showSessionRecordingView {
                SessionRecordingView(showSessionRecordingView: $showSessionRecordingView, showSessionResultView: $showSessionResultView)
                    .environmentObject(cameraViewModel)
                    .environmentObject(dataSenderViewModel)
            } else if showCourseSetupView {
                WaterSkiingCourseSetupView(showCourseSetupView: $showCourseSetupView)
                    .environmentObject(waterSkiingCourseViewModel)
            } else if showSessionResultView {
                SessionResultView(showSessionResultView: $showSessionResultView)
                    .environmentObject(dataReceiverViewModel)
            } else {
                MainView(showCourseSetupView: $showCourseSetupView, showSessionRecordingView: $showSessionRecordingView)
                    .environmentObject(cameraViewModel)
                    .environmentObject(waterSkiingCourseViewModel)
                    .environmentObject(dataSenderViewModel)
            }
        }
    }
    
    /**
     1. Send Session Start to Watch.
     2. Send Session Stop when session needs to be stopped.
     3. When session began recording, start recording video.
     4. When Session has been ended, end recording of the video. AVFoundation framework
     5. Use the start date of video recording to synchronize video with data.
     6. When video has been synchronized, show the data of the session :
     6.a. Data should have information in the format described in slack.
     6.b. Buoy, Wake Cross, Gate should be clickable. Meaning when I FF or FB video, the data table should highlight point of the data that the video is currently represents.
     6.b.a. So, we have additional 2 points between each point of interest that should be highlighted, could simply highlight border of the row to show that.
     */
}

//struct LoadingView: View {
//    @EnvironmentObject var dataReceiverViewModel: DataReceiverViewModel
//
//    init() {
//        testExample()
//    }
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.5)
//                .edgesIgnoringSafeArea(.all)
//
//            VStack {
//                if dataReceiverViewModel.isDeviceConnected && dataReceiverViewModel.isSessionInProgress {
//                    Text("Session in Progress...")
//                        .font(.title)
//                        .foregroundColor(.orange)
//                } else if dataReceiverViewModel.isDeviceConnected && dataReceiverViewModel.isSessionCompleted {
//                    Text("Session has been Completed...")
//                        .font(.title)
//                        .foregroundColor(.orange)
//                } else if dataReceiverViewModel.isDeviceConnected {
//                    Text("Waiting for connection...")
//                        .font(.title)
//                        .foregroundColor(.orange)
//                }
//
//                ActivityIndicatorView()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.orange)
//                    .background(.black.opacity(0.5))
//                    .cornerRadius(10)
//            }
//        }
//    }
//
//    private func getCoordinate(lat: Double, lon: Double) -> Coordinate {
//        return Coordinate(latitude: Measurement(value: lat, unit: .degrees), longitude: Measurement(value: lon, unit: .degrees))
//    }
//
//    func testExample() {
//        let length: Measurement<UnitLength> = Measurement(value: 1, unit: .meters)
//        let angle: Measurement<UnitAngle> = Measurement(value: 1, unit: .degrees)
//
//        let processor = WaterSkiingProcessor(
//            user: WaterSkier(
//                user: User(
//                    name: "Michael",
//                    dateOfBirth: Date(),
//                    username: "Test",
//                    password: "Test"
//                ),
//                ageGroup: .Group_1,
//                ski: Ski(brand: "a", style: "b", length: length, bindingType: "c"),
//                fin: Fin(length: length, depth: length, dft: length, wingAngle: angle, bladeThickness: length)
//            ),
//            boat: Boat(name: "A", driver: BoatDriver(name: "A")),
//            course: WaterSkiingCourse(
//                location: Coordinate(latitude: Measurement(value: 0, unit: .degrees), longitude: Measurement(value: 0, unit: .degrees)),
//                name: "Test",
//                buoys: Array([
//                    getCoordinate(lat: 2, lon: 1),
//                    getCoordinate(lat: 1, lon: 2),
//                    getCoordinate(lat: 2, lon: 3),
//                    getCoordinate(lat: 1, lon: 4),
//                    getCoordinate(lat: 2, lon: 5),
//                    getCoordinate(lat: 1, lon: 6)
//                ]),
//                wakeCrosses: Array([
//                    getCoordinate(lat: 1.5, lon: 0.5),
//                    getCoordinate(lat: 1.5, lon: 1.5),
//                    getCoordinate(lat: 1.5, lon: 2.5),
//                    getCoordinate(lat: 1.5, lon: 3.5),
//                    getCoordinate(lat: 1.5, lon: 4.5),
//                    getCoordinate(lat: 1.5, lon: 5.5)
//                ]),
//                entryGate: getCoordinate(lat: 1.5, lon: 0),
//                exitGate: getCoordinate(lat: 1.5, lon: 6.5)
//            )
//        )
//
//        let trackingRecords = Array([
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 0)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 0.5)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 1)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 1.5)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 2)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 2.5)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 3)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 3.5)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 4)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 4.5)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 5)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 5.5)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 6)),
//            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 6.5))
//        ])
//
//        let result = processor.processPass(records: trackingRecords, videoId: UUID())
//
//        print(result.score)
//    }
//
//    private func generateTrackingRecord(coordinate: Coordinate) -> TrackingRecord {
//        let acceleration: Measurement<UnitAcceleration> = Measurement(value: 0, unit: .metersPerSecondSquared)
//        let angle: Measurement<UnitAngle> = Measurement(value: 1, unit: .degrees)
//        let speed: Measurement<UnitSpeed> = Measurement(value: 0, unit: .metersPerSecond)
//
//        let motionRecord = MotionRecord(
//            attitude: Attitude(roll: angle, yaw: angle, pitch: angle),
//            acceleration: Unit3D(x: acceleration, y: acceleration, z: acceleration),
//            gForce: Unit3D(x: acceleration, y: acceleration, z: acceleration)
//        )
//
//        return TrackingRecord(
//            location: LocationRecord(speed: speed, coordinate: coordinate),
//            motion: motionRecord,
//            timeStamp: Date().timeIntervalSince1970
//        )
//    }
//}
