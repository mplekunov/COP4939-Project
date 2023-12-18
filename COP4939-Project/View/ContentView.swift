//
//  ContentView.swift
//  PhoneApp
//
//  Created by Mikhail Plekunov on 11/20/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dataReceiverViewModel: DataReceiverViewModel = DataReceiverViewModel()
    @StateObject var locationSensorViewModel: DeviceLocationSensorViewModel = DeviceLocationSensorViewModel()
    @State private var isCourseSetup: Bool = false
    @State private var showSetupView: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack {
                Button(isCourseSetup ? "Edit WaterSkiing Course Layout" : "Setup WaterSkiing Course Layout") {
                    showSetupView.toggle()
                }
                .padding()
                .foregroundColor(isCourseSetup ? Color.blue : Color.green)
                .sheet(isPresented: $showSetupView) {
                    WaterSkiingCourseSetupView(showSetupView: $showSetupView, course: nil)
                        .environmentObject(locationSensorViewModel)
                }
                
                Button(isCourseSetup ? "Start WaterSkiing Recording" : "Recording Unavailable") {
                    if isCourseSetup {
                        // Send recording request
                        // End Recording Session through sending another request/or end recording on the watch
                        // use info to display stats
                    }
                }.alert(isPresented: $isCourseSetup) {
                    Alert(
                        title: Text("Course Setup Required"),
                        message: Text("Please set up the course layout before starting recording."),
                        dismissButton: .cancel())
                }
                .padding()
                .foregroundColor(isCourseSetup ? Color.white : Color.gray)
                .disabled(!isCourseSetup)
                .foregroundColor(.orange)
                .environmentObject(dataReceiverViewModel)
            }
        }
    }
}

struct ActivityIndicatorView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .large)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
        /* : uiView.stopAnimating()*/
    }
}

struct LoadingView: View {
    @EnvironmentObject var dataReceiverViewModel: DataReceiverViewModel
    
    init() {
        testExample()
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if dataReceiverViewModel.isDeviceConnected && dataReceiverViewModel.isSessionInProgress {
                    Text("Session in Progress...")
                        .font(.title)
                        .foregroundColor(.orange)
                } else if dataReceiverViewModel.isDeviceConnected && dataReceiverViewModel.isSessionCompleted {
                    Text("Session has been Completed...")
                        .font(.title)
                        .foregroundColor(.orange)
                } else if dataReceiverViewModel.isDeviceConnected {
                    Text("Waiting for connection...")
                        .font(.title)
                        .foregroundColor(.orange)
                }
                
                ActivityIndicatorView()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .background(.black.opacity(0.5))
                    .cornerRadius(10)
            }
        }
    }
    
    private func getCoordinate(lat: Double, lon: Double) -> Coordinate {
        return Coordinate(latitude: Measurement(value: lat, unit: .degrees), longitude: Measurement(value: lon, unit: .degrees))
    }
    
    func testExample() {
        let length: Measurement<UnitLength> = Measurement(value: 1, unit: .meters)
        let angle: Measurement<UnitAngle> = Measurement(value: 1, unit: .degrees)
        
        let processor = WaterSkiingProcessor(
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
            generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 1)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 1.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 2)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 2.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 3)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 3.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 4)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 4.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 2.000005, lon: 5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 5.5)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 0.999995, lon: 6)),
            generateTrackingRecord(coordinate: getCoordinate(lat: 1.5, lon: 6.5))
        ])
        
        let result = processor.processPass(records: trackingRecords, videoId: UUID())
        
        print(result.score)
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
            location: LocationRecord(speed: speed, coordinate: coordinate),
            motion: motionRecord,
            timeStamp: Date().timeIntervalSince1970
        )
    }
}
