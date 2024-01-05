//
//  VideoManager.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/25/23.
//

import Foundation
import AVFoundation

struct VideoManager {
    private let logger: LoggerService
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
    }
    
    func trimVideo(source movieURL: URL, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime) async throws {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        
        let asset = AVAsset(url: movieURL as URL)
        
        let duration = try await asset.load(.duration)
        let mediaType = movieURL.pathExtension
        
        logger.log(message: "MediaType ~ \"\(mediaType)\"")
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputMovieURL
        exportSession.outputFileType = AVFileType(mediaType)
        
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        
        await exportSession.export()
        
        switch exportSession.status {
        case .completed:
            logger.log(message: "Trimming has been successful")
        case .cancelled:
            logger.log(message: "Trimming has been cancelled")
        case .failed:
            logger.log(message: "Trimming has failed")
        default:
            break
        }
    }
}
