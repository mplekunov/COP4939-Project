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
    
    func export(_ asset: AVAsset, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime, composition: AVVideoComposition) async  {
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        
        do {
            try FileManager.default.removeItem(at: outputMovieURL)
        } catch {
            logger.error(message: "\(error)")
        }
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        
        exporter?.videoComposition = composition
        exporter?.outputURL = outputMovieURL
        exporter?.outputFileType = .mov
        exporter?.timeRange = timeRange
        
        await exporter?.export()
    }
}
