//
//  PopOverView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/18/23.
//

import Foundation
import SwiftUI

struct PopOverView: View {
    @EnvironmentObject var locationSensorViewModel: DeviceLocationSensorViewModel
    
    private let fullCoursePointUINames: Dictionary<String, String>
    @Binding var activeElement: CoursePointUI?
    @Binding var coursePointLocations: Dictionary<UUID, Coordinate>
    @Binding var showPopOverView: Bool
    
    init(
        fullCoursePointUINames: Dictionary<String, String>,
        activeElement: Binding<CoursePointUI?>,
        coursePointLocations: Binding<Dictionary<UUID, Coordinate>>,
        showPopOverView: Binding<Bool>
    ) {
        self.fullCoursePointUINames = fullCoursePointUINames
        _activeElement = activeElement
        _coursePointLocations = coursePointLocations
        _showPopOverView = showPopOverView
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("\(fullCoursePointUINames.keys.contains(activeElement!.name) ? fullCoursePointUINames[activeElement!.name]! : "N/A")")
                    .foregroundStyle(.orange)
                    .padding()
                
                VStack {
                    Text("Current Latitude: \(locationSensorViewModel.lastLocation?.coordinate.latitude.formatted() != nil ? locationSensorViewModel.lastLocation!.coordinate.latitude.formatted() : "N/A")")
                        .foregroundStyle(.orange)
                    
                    Text("Current Longitude: \(locationSensorViewModel.lastLocation?.coordinate.longitude.formatted() != nil ? locationSensorViewModel.lastLocation!.coordinate.longitude.formatted() : "N/A")")
                        .foregroundStyle(.orange)
                    
                    Text("Saved Latitude: \(coursePointLocations[activeElement!.id] != nil ? coursePointLocations[activeElement!.id]!.latitude.formatted() : "N/A")")
                        .foregroundStyle(.orange)
                    
                    Text("Saved Longitude: \(coursePointLocations[activeElement!.id] != nil ? coursePointLocations[activeElement!.id]!.longitude.formatted() : "N/A")")
                        .foregroundStyle(.orange)
                }
                .padding()
                
                createButton(text: "Set Location", width: 200, height: nil) {
                    if let currentLocation = locationSensorViewModel.lastLocation {
                        coursePointLocations[activeElement!.id] = currentLocation.coordinate
                    }
                }
                
                createButton(text: "Close", width: 200, height: nil) {
                    locationSensorViewModel.stopRecording()
                    showPopOverView.toggle()
                }
            }
            .padding()
        }
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
