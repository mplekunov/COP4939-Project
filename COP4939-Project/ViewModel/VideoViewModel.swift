//
//  VideoViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/7/24.
//

import Foundation
import AVFoundation

class VideoViewModel : ObservableObject {
    @Published public private(set) var currentTimeStamp: Double?
    @Published public private(set) var duration: Double?
    @Published public private(set) var error: String?
    
    private var playbackObserver: Any?
    
    public private(set) var player: AVPlayer?
    
    func startPlayback(video: Video<URL>) {
        error = nil
        
        player = AVPlayer(url: video.fileLocation)
        
        DispatchQueue.main.async {
            Task {
                self.duration = try await self.player?.currentItem?.asset.load(.duration).seconds
            }
        }
        
        guard let player = player else {
            error = "Player could not be initialized"
            return
        }
        
        
        playbackObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.currentTimeStamp = CMTimeGetSeconds(time)
            }
        }
    }
    
    
    func seekTo(timeStamp: Double) {
        guard let player = player else { return }
        
        let seekTime = CMTime(seconds: timeStamp, preferredTimescale: 1)
        let tolerance = CMTime(seconds: 1, preferredTimescale: 2)
        
        player.seek(to: seekTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
    }
}
