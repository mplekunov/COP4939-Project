//
//  WaterSkiingCourseSetupFromVideoView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation
import SwiftUI
import AVKit

private var buoysUI: [CoursePointUI] = [
    CoursePointUI(name: "B 1", position: CGPoint(x: 0.75, y: 0.88), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 2", position: CGPoint(x: 0.25, y: 0.76), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 3", position: CGPoint(x: 0.75, y: 0.64), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 4", position: CGPoint(x: 0.25, y: 0.54), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 5", position: CGPoint(x: 0.75, y: 0.40), setColor: .orange, unsetColor: .gray),
    CoursePointUI(name: "B 6", position: CGPoint(x: 0.25, y: 0.28), setColor: .orange, unsetColor: .gray)
]

private var wakeCrossesUI: [CoursePointUI] = [
    CoursePointUI(name: "W 1", position: CGPoint(x: 0.5, y: 0.82), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 2", position: CGPoint(x: 0.5, y: 0.70), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 3", position: CGPoint(x: 0.5, y: 0.58), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 4", position: CGPoint(x: 0.5, y: 0.46), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 5", position: CGPoint(x: 0.5, y: 0.34), setColor: .yellow, unsetColor: .gray),
    CoursePointUI(name: "W 6", position: CGPoint(x: 0.5, y: 0.22), setColor: .yellow, unsetColor: .gray)
]

private var entryGateUI: CoursePointUI =
CoursePointUI(name: "S", position: CGPoint(x: 0.5, y: 0.95), setColor: .green, unsetColor: .gray)
private var exitGateUI: CoursePointUI =
CoursePointUI(name: "F", position: CGPoint(x: 0.5, y: 0.1), setColor: .red, unsetColor: .gray)

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

struct WaterSkiingCourseSetupFromVideoView : View {
    @EnvironmentObject var videoViewModel: VideoViewModel
    @EnvironmentObject var waterSkiingCourseViewModel: WaterSkiingCourseViewModel<WaterSkiingCourseFromVideo>
    
    @State private var isPlaying = false
    @State private var showPlayButton = false
    @State private var showTimeStamp = false
    @State private var isSeeking = false
    
    @State private var alert: AlertInfo?
    
    @State private var coursePointToVideoTimeStamp: Dictionary<UUID, Double> = [:]
    @State private var activeCoursePoint: UUID?
    @State private var showAlert = false
    
    @Binding var showResultsView: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                VideoPlayer(player: videoViewModel.player)
                    .onAppear {
                        videoViewModel.startPlayback(video: Video<URL>(id: UUID(), creationDate: 0, fileLocation: Bundle.main.url(forResource: "video", withExtension: "mp4")!))
                        
                        togglePlayback()
                    }
                    .onTapGesture(perform: {
                        togglePlayback()
                    })
                    .overlay(content: {
                        VStack(alignment: .center) {
                            Spacer()
                            Spacer()
                            VStack {
                                if showPlayButton {
                                    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 50))
                                        .onTapGesture(perform: togglePlayback)
                                        .padding()
                                }
                            }
                            
                            if showTimeStamp {
                                Text(formatTime(seconds: coursePointToVideoTimeStamp[activeCoursePoint!] ?? 0))
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 30))
                            }
                            Spacer()
                            
                            HStack {
                                Text(formatTime(seconds: videoViewModel.currentTimeStamp ?? 0))
                                    .foregroundStyle(.orange)
                                Spacer()
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(height: 14)
                                        .background(.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.orange, lineWidth: 1)
                                        )
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    guard let duration = videoViewModel.duration else { return }
                                                    isSeeking = true
                                                    let newTime = (value.location.x / 250) * duration
                                                    
                                                    videoViewModel.seekTo(timeStamp: min(duration, max(0, newTime)))
                                                }
                                                .onEnded { _ in
                                                    isSeeking = false
                                                }
                                        )
                                    
                                    Rectangle()
                                        .frame(width:  (videoViewModel.currentTimeStamp ?? 0) * (250 / (videoViewModel.duration ?? 1)), height: 14)
                                        .foregroundColor(.orange)
                                        .background(.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.orange, lineWidth: 0.4)
                                        )
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    guard let duration = videoViewModel.duration else { return }
                                                    isSeeking = true
                                                    let newTime = (value.location.x / 250) * duration
                                                    
                                                    videoViewModel.seekTo(timeStamp: min(duration, max(0, newTime)))
                                                }
                                                .onEnded { _ in
                                                    isSeeking = false
                                                }
                                        )
                                }
                                .frame(width: 250, height: 20)
                                
                                
                                Spacer()
                                Text(formatTime(seconds: videoViewModel.duration ?? 0))
                                    .foregroundStyle(.orange)
                            }
                            .padding()
                        }
                    })
                    .onDisappear {
                        guard let player = videoViewModel.player else { return }
                        player.pause()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.orange, lineWidth: 1)
                    )
                    .frame(height: 300)
                
                drawCourse()
                
            }.alert(
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
    }
    
    private func formatTime(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? ""
    }
    
    private func togglePlayback() {
        guard let player = videoViewModel.player else { return }
        
        showPlayButton = true
        
        if !isPlaying {
            player.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showPlayButton = false
            }
        } else {
            player.pause()
        }
        
        isPlaying.toggle()
    }
    
    private func initCourse(course: WaterSkiingCourseFromVideo) {
        DispatchQueue.main.async {
            var i = 0
            
            course.buoyPositions.forEach({ buoy in
                coursePointToVideoTimeStamp.updateValue(buoy, forKey: buoysUI[i].id)
                i += 1
            })
            
            i = 0
            
            course.wakeCrossPositions.forEach({ wakeCross in
                coursePointToVideoTimeStamp.updateValue(wakeCross, forKey: wakeCrossesUI[i].id)
                i += 1
            })
            
            coursePointToVideoTimeStamp.updateValue(course.entryGatePosition, forKey: entryGateUI.id)
            coursePointToVideoTimeStamp.updateValue(course.exitGatePosition, forKey: exitGateUI.id)
        }
    }
    
    private func drawCourseElement(element: CoursePointUI, geometry: GeometryProxy) -> some View {
        return ZStack {
            Circle()
                .fill(coursePointToVideoTimeStamp.keys.contains(element.id) ? element.setColor : element.unsetColor)
                .frame(width: 40, height: 40)
                .onTapGesture {
                    coursePointToVideoTimeStamp[element.id] = videoViewModel.currentTimeStamp
                    activeCoursePoint = element.id
                    
                    showTimeStamp = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showTimeStamp = false
                    }
                }
                .onLongPressGesture {
                    showTimeStamp = true
                    activeCoursePoint = element.id
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showTimeStamp = false
                    }
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
    
    private func saveCourse() -> WaterSkiingCourseFromVideo {
        var buoys = Array<Double>()
        var wakeCrosses = Array<Double>()
        let entryGate = coursePointToVideoTimeStamp[entryGateUI.id] ?? 0.0
        let exitGate = coursePointToVideoTimeStamp[exitGateUI.id] ?? 0.0
        
        buoysUI.forEach({ buoy in
            buoys.append(coursePointToVideoTimeStamp[buoy.id] ?? 0.0)
        })
        
        wakeCrossesUI.forEach({ wakeCross in
            wakeCrosses.append(coursePointToVideoTimeStamp[wakeCross.id] ?? 0.0)
        })
        
        return WaterSkiingCourseFromVideo(
            totalScore: 0,
            buoyPositions: buoys,
            wakeCrossPositions: wakeCrosses,
            entryGatePosition: entryGate,
            exitGatePosition: exitGate
        )
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
            
            createButton(text: "Next", width: 300, height: nil) {
                if coursePointToVideoTimeStamp.keys.count == fullCoursePointUINames.count {
                    waterSkiingCourseViewModel.setCourse(saveCourse())
                    showResultsView = true
                } else {
                    alert = AlertInfo(
                        id: .WaterSkiingCourse,
                        title: "Course data",
                        message: "Please set up all course points before saving course.")
                    
                    showAlert = true
                }
            }
        }
    }
}

//struct WaterSkiingCourseSetupFromVideoViewPreview: PreviewProvider {
//    @StateObject static var videoViewModel = VideoViewModel()
//    @StateObject static var courseViewModel = WaterSkiingCourseViewModel<WaterSkiingCourseFromVideo>(courseFileName: "CourseFile.txt")
//    
//    static var previews: some View {
//        WaterSkiingCourseSetupFromVideoView()
//            .environmentObject(videoViewModel)
//            .environmentObject(courseViewModel)
//            .onAppear(perform: {
//                videoViewModel.startPlayback(video: Video<URL>(id: UUID(), creationDate: 0, fileLocation: Bundle.main.url(forResource: "video", withExtension: "mp4")!))
//            })
//    }
//}
