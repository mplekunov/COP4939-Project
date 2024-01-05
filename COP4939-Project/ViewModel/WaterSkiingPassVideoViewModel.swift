//
//  VidePlaybackViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/24/23.
//

import Foundation
import AVFoundation

class WaterSkiingPassVideoViewModel : ObservableObject {
    @Published public private(set) var curentPlayingRecord: WaterSkiingObjectRecord?
    @Published public private(set) var error: String?
   
    public private(set) var objectRecords: [WaterSkiingObjectRecord] = []
    private var currentObjectRecordIndex = -1
    
    private var objectIndexToBuoys: Dictionary<Int, Buoy> = [:]
    private var objectIndexToGates: Dictionary<Int, Gate> = [:]
    private var objectIndexToWakeCrosses: Dictionary<Int, WakeCross> = [:]
    
    private var videoTimeStampToObjectRecordIndex: Dictionary<Double, Int> = [:]
    
    private var playbackObserver: Any?
    
    private let operationQueue: OperationQueue = OperationQueue()
    
    public private(set) var player: AVPlayer?
    
    func startPlayback(pass: Pass) {
        error = nil
        
        guard let videoFile = pass.videoFile else {
            error = "Video file is not assigned to the pass"
            return
        }
        
        player = AVPlayer(url: videoFile.url)
        
        guard let player = player else {
            error = "Player could not be initialized"
            return
        }
        
        playbackObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            
            let timeInSeconds = CMTimeGetSeconds(time)
            
            if currentObjectRecordIndex + 1 < objectRecords.count &&
                objectRecords[currentObjectRecordIndex + 1].videoTimeStampInSeconds < timeInSeconds {
                currentObjectRecordIndex += 1
            }
        }
        
        configure(pass: pass)
    }
    
    func seekTo(record: WaterSkiingObjectRecord) {
        guard let player = player else { return }
        
        let seekTime = CMTime(seconds: record.videoTimeStampInSeconds, preferredTimescale: 1)
        let tolerance = CMTime(seconds: 1, preferredTimescale: 2)
        
        player.seek(to: seekTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
        
        guard let index = videoTimeStampToObjectRecordIndex[record.videoTimeStampInSeconds] else {
            curentPlayingRecord = nil
            currentObjectRecordIndex = -1
            return
        }
        
        curentPlayingRecord = objectRecords[index]
        currentObjectRecordIndex = index - 1
    }
    
    private func configure(pass: Pass) {
        objectIndexToGates[0] = pass.entryGate
        
        videoTimeStampToObjectRecordIndex[pass.entryGate.timeOfRecordingInSeconds] = 0
        
        objectRecords.append(WaterSkiingObjectRecord(
            objectName: "Entry Gate",
            objectIndex: 0,
            objectType: .EntryGate,
            videoTimeStampInSeconds: pass.entryGate.timeOfRecordingInSeconds)
        )
        
        var i = 0, j = 0
        
        let totalCount = pass.buoys.count + pass.wakeCrosses.count
        
        for index in 0..<totalCount {
            if index % 2 == 0 {
                objectIndexToWakeCrosses[i] = pass.wakeCrosses[i]
                videoTimeStampToObjectRecordIndex[pass.wakeCrosses[i].timeOfRecordingInSeconds] = objectRecords.count
                
                objectRecords.append(WaterSkiingObjectRecord(
                    objectName: "Wake Cross \(i + 1)",
                    objectIndex: i,
                    objectType: .WakeCross,
                    videoTimeStampInSeconds: pass.wakeCrosses[i].timeOfRecordingInSeconds)
                )
                
                i += 1
            } else {
                objectIndexToBuoys[j] = pass.buoys[j]
                videoTimeStampToObjectRecordIndex[pass.buoys[j].timeOfRecordingInSeconds] = objectRecords.count
                
                objectRecords.append(WaterSkiingObjectRecord(
                    objectName: "Buoy \(j + 1)",
                    objectIndex: j,
                    objectType: .Buoy,
                    videoTimeStampInSeconds: pass.buoys[j].timeOfRecordingInSeconds)
                )
                
                j += 1
            }
        }
        
        objectIndexToGates[objectRecords.count] = pass.exitGate
        videoTimeStampToObjectRecordIndex[pass.exitGate.timeOfRecordingInSeconds] = objectRecords.count
        
        objectRecords.append(WaterSkiingObjectRecord(
            objectName: "Exit Gate",
            objectIndex: objectRecords.count,
            objectType: .ExitGate,
            videoTimeStampInSeconds: pass.exitGate.timeOfRecordingInSeconds)
        )
    }
    
    func getBuoyByIndex(_ index: Int) -> Buoy? {
        return objectIndexToBuoys[index]
    }
    
    func getGateByIndex(_ index: Int) -> Gate? {
        return objectIndexToGates[index]
    }
    
    func getWakeCrossByIndex(_ index: Int) -> WakeCross? {
        return objectIndexToWakeCrosses[index]
    }
}
