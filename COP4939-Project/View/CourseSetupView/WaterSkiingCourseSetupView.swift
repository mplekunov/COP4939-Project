//
//  WaterSkiingCourseSetupView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/15/23.
//

import Foundation
import SwiftUI
import MapKit
import Combine

private var buoysUI: [CoursePointUI] = [
    CoursePointUI(name: "B 1", position: CGPoint(x: 0.75, y: 0.75), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 2", position: CGPoint(x: 0.25, y: 0.65), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 3", position: CGPoint(x: 0.75, y: 0.55), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 4", position: CGPoint(x: 0.25, y: 0.45), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 5", position: CGPoint(x: 0.75, y: 0.35), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 6", position: CGPoint(x: 0.25, y: 0.25), setColor: .orange, unsetColor: .gray)
]

private var wakeCrossesUI: [CoursePointUI] = [
    CoursePointUI(name: "W 1", position: CGPoint(x: 0.5, y: 0.8), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 2", position: CGPoint(x: 0.5, y: 0.7), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 3", position: CGPoint(x: 0.5, y: 0.6), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 4", position: CGPoint(x: 0.5, y: 0.5), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 5", position: CGPoint(x: 0.5, y: 0.4), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 6", position: CGPoint(x: 0.5, y: 0.3), setColor: .yellow, unsetColor: .gray)
]

private var entryGateUI: CoursePointUI =
    CoursePointUI(name: "S", position: CGPoint(x: 0.5, y: 0.9), setColor: .green, unsetColor: .gray)
private var exitGateUI: CoursePointUI =
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

struct WaterSkiingCourseSetupView: View {
    private let logger: LoggerService
    
    @State private var alert: AlertInfo?
    
    @EnvironmentObject var waterSkiingCourseViewModel: WaterSkiingCourseViewModel
    
    @Binding private var showCourseSetupView: Bool
    
    @State private var showPopOverView = false
    @State private var activeElement: CoursePointUI?
    @State private var coursePointLocations: Dictionary<UUID, Coordinate> = [:]
    @State private var coursePointLocation: Coordinate?
    @State private var showAlert = false
    
    init(showCourseSetupView: Binding<Bool>) {
        _showCourseSetupView = showCourseSetupView
        
        logger = LoggerService(logSource: String(describing: type(of: self)))
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if showPopOverView {
                WaterSkiingCoursePointSetupView(
                    activeElement: $activeElement,
                    coursePointLocation: $coursePointLocation,
                    coursePointLocations: $coursePointLocations,
                    showPopOverView: $showPopOverView,
                    alert: $alert,
                    showAlert: $showAlert
                )
                .onAppear(perform: {
                    guard let activeElement = activeElement else { return }
                
                    coursePointLocation = coursePointLocations[activeElement.id]
                })
            } else {
                drawCourse()
            }
        }
        .alert(
            alert?.title ?? "",
            isPresented: $showAlert,
            actions: {
                Button("Ok") {
                    showAlert = false
                }
            },
            message: {
                Text(alert?.message ?? "")
            }
        )
        .onAppear(perform: {
            guard let course = waterSkiingCourseViewModel.course else { return }
            
            initCourse(course: course)
        })
    }
    
    private func drawCourse() -> some View {
        return VStack {
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
                    waterSkiingCourseViewModel.setCourse(saveCourse())
                    showCourseSetupView = false
                } else {
                    alert = AlertInfo(
                        id: .WaterSkiingCourse,
                        title: "Course data",
                        message: "Please set up all course points before saving course.")
                    
                    showAlert = true
                }
            }
            
            createButton(text: "Close", width: 300, height: nil) {
                showCourseSetupView.toggle()
            }
        }
    }
    
    private func initCourse(course: WaterSkiingCourse) {
        DispatchQueue.main.async {
            var i = 0
            
            course.buoys.forEach({ buoy in
                coursePointLocations.updateValue(buoy, forKey: buoysUI[i].id)
                i += 1
            })
            
            i = 0
            
            course.wakeCrosses.forEach({ wakeCross in
                coursePointLocations.updateValue(wakeCross, forKey: wakeCrossesUI[i].id)
                i += 1
            })
            
            coursePointLocations.updateValue(course.entryGate, forKey: entryGateUI.id)
            coursePointLocations.updateValue(course.exitGate, forKey: exitGateUI.id)
        }
    }
    
    private func saveCourse() -> WaterSkiingCourse {
        let defaultCoordinate = Coordinate(latitude: Measurement(value: 0, unit: .degrees), longitude: Measurement(value: 0, unit: .degrees))
        
        var buoys = Array<Coordinate>()
        var wakeCrosses = Array<Coordinate>()
        let entryGate = coursePointLocations[entryGateUI.id] ?? defaultCoordinate
        let exitGate = coursePointLocations[exitGateUI.id] ?? defaultCoordinate
        
        buoysUI.forEach({ buoy in
            buoys.append(coursePointLocations[buoy.id] ?? defaultCoordinate)
        })
        
        wakeCrossesUI.forEach({ wakeCross in
            wakeCrosses.append(coursePointLocations[wakeCross.id] ?? defaultCoordinate)
        })
        
        return WaterSkiingCourse(
            location: buoys.first ?? defaultCoordinate,
            name: UUID().uuidString,
            buoys: buoys,
            wakeCrosses: wakeCrosses,
            entryGate: entryGate,
            exitGate: exitGate
        )
    }
    
    private func drawCourseElement(element: CoursePointUI, geometry: GeometryProxy) -> some View {
        return ZStack {
            Circle()
                .fill(coursePointLocations.keys.contains(element.id) ? element.setColor : element.unsetColor)
                .frame(width: 50, height: 50)
                .onTapGesture {
                    activeElement = CoursePointUI(
                        id: element.id,
                        name: fullCoursePointUINames[element.name] ?? element.name,
                        position: element.position,
                        setColor: element.setColor,
                        unsetColor: element.unsetColor
                    )
                    
                    showPopOverView = true
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
