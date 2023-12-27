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
    
    init(waterSkiingCourseViewModel: WaterSkiingCourseViewModel, cameraViewModel: CameraViewModel, sessionViewModel: SessionViewModel ) {
        Publishers.CombineLatest3(waterSkiingCourseViewModel.$course, cameraViewModel.$videoFile, sessionViewModel.$session)
            .receive(on: DispatchQueue.main)
            .compactMap { course, videoFile, session in
                guard let course = course, let videoFile = videoFile, let session = session else { return nil }
                
                let processor = WaterSkiingPassProcessor()
                
                return processor.processPass(course: course, records: session.data, videoFile: videoFile)
            }
            .assign(to: &$pass)
    }
}
