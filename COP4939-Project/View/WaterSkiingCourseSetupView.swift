//
//  WaterSkiingCourseSetupView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/15/23.
//

import Foundation
import SwiftUI
import MapKit

struct WaterSkiingCourseSetupView: View {
    private let logger: LoggerService
    
    @EnvironmentObject var locationSensorViewModel: DeviceLocationSensorViewModel
    @State private var showPopOverView = false
    @State private var activeElement: CoursePointUI? = nil
    @State private var coursePointLocations: Dictionary<UUID, Coordinate> = [:]
    
    @Binding private var showSetupView: Bool
    
    @State private var showAlert: Bool = false
    
    @State private var buoysUI: [CoursePointUI] = [
        CoursePointUI(name: "B 1", position: CGPoint(x: 0.75, y: 0.75), setColor: .orange, unsetColor: .gray),
        CoursePointUI(name: "B 2", position: CGPoint(x: 0.25, y: 0.65), setColor: .orange, unsetColor: .gray),
        CoursePointUI(name: "B 3", position: CGPoint(x: 0.75, y: 0.55), setColor: .orange, unsetColor: .gray),
        CoursePointUI(name: "B 4", position: CGPoint(x: 0.25, y: 0.45), setColor: .orange, unsetColor: .gray),
        CoursePointUI(name: "B 5", position: CGPoint(x: 0.75, y: 0.35), setColor: .orange, unsetColor: .gray),
        CoursePointUI(name: "B 6", position: CGPoint(x: 0.25, y: 0.25), setColor: .orange, unsetColor: .gray)
    ]
    
    @State private var wakeCrossesUI: [CoursePointUI] = [
        CoursePointUI(name: "W 1", position: CGPoint(x: 0.5, y: 0.8), setColor: .yellow, unsetColor: .gray),
        CoursePointUI(name: "W 2", position: CGPoint(x: 0.5, y: 0.7), setColor: .yellow, unsetColor: .gray),
        CoursePointUI(name: "W 3", position: CGPoint(x: 0.5, y: 0.6), setColor: .yellow, unsetColor: .gray),
        CoursePointUI(name: "W 4", position: CGPoint(x: 0.5, y: 0.5), setColor: .yellow, unsetColor: .gray),
        CoursePointUI(name: "W 5", position: CGPoint(x: 0.5, y: 0.4), setColor: .yellow, unsetColor: .gray),
        CoursePointUI(name: "W 6", position: CGPoint(x: 0.5, y: 0.3), setColor: .yellow, unsetColor: .gray)
    ]
    
    @State private var entryGateUI: CoursePointUI =
        CoursePointUI(name: "S", position: CGPoint(x: 0.5, y: 0.9), setColor: .green, unsetColor: .gray)
    @State private var exitGateUI: CoursePointUI =
        CoursePointUI(name: "F", position: CGPoint(x: 0.5, y: 0.2), setColor: .red, unsetColor: .gray)
    
    private let fullCoursePointUINames: Dictionary<String, String> = [
        "B 1" : "Buoy 1",
        "B 2" : "Buoy 2",
        "B 3" : "Buoy 3",
        "B 4" : "Buoy 4",
        "B 5" : "Buoy 5",
        "B 6" : "Buoy 6",
        "W 1" : "Wake Cross 1",
        "W 2" : "Wake Cross 2",
        "W 3" : "Wake Cross 3",
        "W 4" : "Wake Cross 4",
        "W 5" : "Wake Cross 5",
        "W 6" : "Wake Cross 6",
        "S" : "Start/Entry Gate",
        "F" : "Finish/Exit Gate"
    ]
    
    init(showSetupView: Binding<Bool>, course: WaterSkiingCourse?) {
        _showSetupView = showSetupView
        
        logger = LoggerService(logSource: String(describing: type(of: self)))
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if showPopOverView && locationSensorViewModel.startRecording() {
                PopOverView(
                    fullCoursePointUINames: fullCoursePointUINames,
                    activeElement: $activeElement,
                    coursePointLocations: $coursePointLocations,
                    showPopOverView: $showPopOverView
                )
            } else {
                VStack {
                    GeometryReader { geometry in
                        ZStack {
                            drawCourseElements(elements: buoysUI, geometry: geometry)
                            drawCourseElements(elements: wakeCrossesUI, geometry: geometry)
                            drawCourseElement(element: entryGateUI, geometry: geometry)
                            drawCourseElement(element: exitGateUI, geometry: geometry)
                        }
                        .background(.primary)
                    }
                    
                    createButton(text: "Save Course", width: 300, height: nil) {
                        if coursePointLocations.keys.count == fullCoursePointUINames.count {
                            showSetupView.toggle()
                        } else {
                            showAlert.toggle()
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Course data is not complete"),
                            message: Text("Please set up all course points before saving course."),
                            dismissButton: .cancel()
                        )
                    }
                    
                    createButton(text: "Close", width: 300, height: nil) {
                        showSetupView.toggle()
                    }
                }
            }
        }
    }
    
    private func drawCourseElement(element: CoursePointUI, geometry: GeometryProxy) -> some View {
        return ZStack {
            Circle()
                .fill(coursePointLocations.keys.contains(element.id) ? element.setColor : element.unsetColor)
                .frame(width: 50, height: 50)
                .onTapGesture {
                    activeElement = element
                    showPopOverView.toggle()
                }
            
            Text("\(element.name)").foregroundStyle(.primary)
        }
        .position(
            x: geometry.size.width * element.position.x,
            y: geometry.size.height * element.position.y
        )
    }
    
    private func drawCourseElements(elements: Array<CoursePointUI>, geometry: GeometryProxy) -> ForEach<[CoursePointUI], UUID, some View> {
        return ForEach(elements) { point in
            drawCourseElement(element: point, geometry: geometry)
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

#Preview {
    WaterSkiingCourseSetupView(showSetupView: .constant(true), course: nil)
}
