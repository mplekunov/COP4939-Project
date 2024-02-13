//
//  PopOverView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/18/23.
//

import Foundation
import SwiftUI

struct WaterSkiingCoursePointSetupView: View {
    @Binding var activeElement: CoursePointUI?
    @Binding var coursePointLocation: Coordinate?
    @Binding var coursePointLocations: Dictionary<UUID, Coordinate>
    @Binding var showPopOverView: Bool
    @Binding var alert: AlertInfo?
    @Binding var showAlert: Bool
    
    @State var currentLocation: LocationRecord?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack {
                Text("\(activeElement?.name ?? "N/A")")
                    .foregroundStyle(.orange)
                    .padding()
                
                VStack(alignment: .leading) {
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
                    guard let activeElement = activeElement else { return }
                    
                    coursePointLocation = currentLocation.coordinate
                    
                    coursePointLocations[activeElement.id] = coursePointLocation
                }
                
                createButton(text: "Close", width: 200, height: nil) {
                    showPopOverView = false
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

struct WaterSkiingCoursePointsSetupViewPreviewView : PreviewProvider {
    static var previews: some View {
        WaterSkiingCoursePointSetupView(
            activeElement: .constant(nil),
            coursePointLocation: .constant(nil),
            coursePointLocations: .constant(Dictionary<UUID, Coordinate>()),
            showPopOverView: .constant(true),
            alert: .constant(nil),
            showAlert: .constant(false)
        )
    }
}
