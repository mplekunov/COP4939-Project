//
//  PopOverView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/18/23.
//

import Foundation
import SwiftUI

struct WaterSkiingCoursePointSetupView: View {
    @StateObject var locationSensorViewModel: DeviceLocationSensorViewModel = DeviceLocationSensorViewModel()
    
    @Binding var activeElement: CoursePointUI?
    @Binding var coursePointLocation: Coordinate?
    @Binding var showPopOverView: Bool
    @Binding var alert: AlertInfo?
    @Binding var showAlert: Bool
    
    @State var currentLocation: LocationRecord?
    
    var body: some View {
        ZStack {
            VStack {
                Text("\(activeElement?.name ?? "N/A")")
                    .foregroundStyle(.orange)
                    .padding()
                
                VStack {
                    Text("Current Latitude: \(currentLocation?.coordinate.latitude.formatted() ?? "N/A")")
                        .foregroundStyle(.orange)
                    
                    Text("Current Longitude: \(currentLocation?.coordinate.longitude.formatted() ?? "N/A")")
                        .foregroundStyle(.orange)
                    
                    Text("Saved Latitude: \(coursePointLocation?.latitude.formatted() ?? "N/A")")
                        .foregroundStyle(.orange)
                    
                    Text("Saved Longitude: \(coursePointLocation?.longitude.formatted() ?? "N/A")")
                        .foregroundStyle(.orange)
                }
                .padding()
                
                createButton(text: "Set Location", width: 200, height: nil) {
                    guard let currentLocation = currentLocation else { return }
                    
                    coursePointLocation = currentLocation.coordinate
                }
                
                createButton(text: "Close", width: 200, height: nil) {
                    showPopOverView = false
                }
            }
            .padding()
        }
        .onReceive(locationSensorViewModel.$lastLocation, perform: { lastLocation in
            guard let lastLocation = lastLocation else { return }
            
            currentLocation = lastLocation
        })
        .onAppear(perform: {
            locationSensorViewModel.startRecording()
        })
        .onDisappear(perform: {
            locationSensorViewModel.stopRecording()
        })
        .onReceive(locationSensorViewModel.$error, perform: { error in
            if error != nil {
                alert = AlertInfo(
                    id: .LocationManager,
                    title: "Location Manager Error",
                    message: "\(error?.description ?? "Something went wrong when app tried to access Location Services.")"
                )
                
                showAlert = true
                
                showPopOverView = false
            }
        })
    }
    
    private func createButton(
        text: String,
        width: CGFloat?,
        height: CGFloat?,
        action: @escaping () -> Void
    ) -> some View {
        return Button(text, action: action)
        .frame(width: width, height: height)
        .padding()
        .background(.orange)
        .foregroundStyle(.black)
        .clipShape(.rect(cornerRadius: 20))
    }
}
