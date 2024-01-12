//
//  WaterSkiingPassViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/26/23.
//

import Foundation
import Combine

class WaterSkiingPassViewModel : ObservableObject {
    @Published var pass: Pass<Double, URL>?
    
    private var logger: LoggerService
    
    private var passSubscriber: AnyCancellable?
    
    init(waterSkiingCourseViewModel: WaterSkiingCourseViewModel<Double>, cameraViewModel: CameraViewModel, sessionViewModel: BaseSessionViewModel) {
        logger = LoggerService(logSource: String(describing: type(of: self)))
        
        passSubscriber = Publishers.CombineLatest3(waterSkiingCourseViewModel.$course, cameraViewModel.$videoFile, sessionViewModel.$session)
            .sink { course, videoFile, session in
                guard let course = course, let videoFile = videoFile, let session = session else { return }
                
                let processor = WaterSkiingPassProcessorForVideo()
                
                Task {
                    self.pass = await processor.process(course: course, totalScore: 0, records: session.data, video: videoFile)
                }
            }
    }
}
