//
//  VideoManager.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/25/23.
//

import Foundation
import AVFoundation

class VideoManager : ObservableObject {
    private let logger: LoggerService
    
    @Published public private(set) var error: String?
    
    init() {
        logger = LoggerService(logSource: String(describing: type(of: self)))
    }
    
    private func fileExtensionToAVFileType(_ fileExtension: String) -> AVFileType? {
        switch fileExtension {
        case "mp4":
            return .mp4
        case "mov":
            return .mov
        default:
            return nil
        }
    }
    
    func trimVideo(source movieURL: URL, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime) async throws {
        error = nil
        
        let asset = AVAsset(url: movieURL as URL)
        
        let mediaType = fileExtensionToAVFileType(movieURL.pathExtension)
        
        guard let mediaType = mediaType else {
            error = "Source file type is not supported"
            return
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            error = "Export session could not be initialized"
            return
        }
        
        
        if FileManager.default.fileExists(atPath: outputMovieURL.path()) {
            error = "Output file with such name already exists"
            return
        }
        
        exportSession.outputURL = outputMovieURL
        exportSession.outputFileType = mediaType
        
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        
        await exportSession.export()
        
        switch exportSession.status {
        case .cancelled:
            error = "Trimming has been cancelled"
        case .failed:
            error = "Trimming has failed"
        case .unknown:
            error = "Unknown error has been encountered"
        default:
            break
        }
    }
}
