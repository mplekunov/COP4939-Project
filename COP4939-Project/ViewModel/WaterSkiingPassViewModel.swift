//
//  WaterSkiingPassViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/26/23.
//

import Foundation
import Combine

class WaterSkiingPassViewModel : ObservableObject {
    @Published var pass: Pass?
    
    private var logger: LoggerService
    
    init(waterSkiingCourseViewModel: WaterSkiingCourseViewModel, cameraViewModel: CameraViewModel, sessionViewModel: SessionViewModel ) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        Publishers.CombineLatest3(waterSkiingCourseViewModel.$course, cameraViewModel.$videoFile, sessionViewModel.$session)
            .receive(on: DispatchQueue.main)
            .compactMap { course, videoFile, session in
                guard let course = course, let videoFile = videoFile, let session = session else { return nil }
                
                let processor = WaterSkiingPassProcessor()
                
                let pass = processor.processPass(course: course, records: session.data, videoFile: videoFile)
                
                if let pass = pass {
                    self.writeToFile(course: course, pass: pass)
                }
                
                return pass
            }
            .assign(to: &$pass)
    }
    
    private func writeToFile(course: WaterSkiingCourse, pass: Pass) {
        if let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let id = UUID().uuidString
            let dataUrl = url.appendingPathComponent(id + "-Data.csv")
            
            var csvData = "Position Type,Position Location(latitude),Position Location(longitude),Skier Location (latitude),Skier Location(longitude),Max Pitch, Max Roll, Max Speed,Max Acceleration,Max Angle,Max G-Force\n"
            
            csvData.append("Entry Gate,\(course.entryGate.latitude.formatted()),\(course.entryGate.longitude.formatted()),\(pass.entryGate.location.latitude.formatted()),\(pass.entryGate.location.longitude.formatted()),\(pass.entryGate.maxPitch.formatted()),\(pass.entryGate.maxRoll.formatted()),\(pass.entryGate.maxSpeed.formatted()),N/A,N/A,N/A\n")
            
            var i = 0
            
            while i < pass.buoys.count {
                csvData.append("Wake Cross \(i),\(course.wakeCrosses[i].latitude.formatted()),\(course.wakeCrosses[i].longitude.formatted()),\(pass.wakeCrosses[i].location.latitude.formatted()),\(pass.wakeCrosses[i].location.longitude.formatted()),\(pass.wakeCrosses[i].maxPitch.formatted()),\(pass.wakeCrosses[i].maxRoll.formatted()),\(pass.wakeCrosses[i].maxSpeed.formatted()),\(pass.wakeCrosses[i].maxAcceleration.formatted()),\(pass.wakeCrosses[i].maxAngle.formatted()),\(pass.wakeCrosses[i].maxGForce.formatted())\n")
                
                
                csvData.append("Buoy \(i),\(course.buoys[i].latitude.formatted()),\(course.buoys[i].longitude.formatted()),\(pass.buoys[i].location.latitude.formatted()),\(pass.buoys[i].location.longitude.formatted()),\(pass.buoys[i].maxPitch.formatted()),\(pass.buoys[i].maxRoll.formatted()),\(pass.buoys[i].maxSpeed.formatted()),N/A,N/A,N/A\n")
                
                i += 1
            }
            
            csvData.append("Exit Gate,\(course.exitGate.latitude.formatted()),\(course.exitGate.longitude.formatted()),\(pass.exitGate.location.latitude.formatted()),\(pass.exitGate.location.longitude.formatted()),\(pass.exitGate.maxPitch.formatted()),\(pass.exitGate.maxRoll.formatted()),\(pass.exitGate.maxSpeed.formatted()),N/A,N/A,N/A\n")
            
            do {
                try csvData.write(to: dataUrl, atomically: true, encoding: .utf8)
            } catch {
                logger.error(message: "\(error)")
            }
        }
    }
}
