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
    
    private var objectIndexToBuoys: Dictionary<Int, BuoyBase<Double>> = [:]
    private var objectIndexToGates: Dictionary<Int, GateBase<Double>> = [:]
    private var objectIndexToWakeCrosses: Dictionary<Int, WakeCrossBase<Double>> = [:]
    
    private var videoTimeStampToObjectRecordIndex: Dictionary<Double, Int> = [:]
    
    private var playbackObserver: Any?
    
    private let operationQueue: OperationQueue = OperationQueue()
    
    public private(set) var player: AVPlayer?
    
    private var videoCreationDateInSeconds: Double?
    
    func startPlayback(pass: Pass<Double, URL>) {
        error = nil
        
        guard let videoFile = pass.videoFile else {
            error = "Video file is not assigned to the water skiing pass"
            return
        }
        
        player = AVPlayer(url: videoFile.fileLocation)
        
        videoCreationDateInSeconds = videoFile.creationDate
        
        guard let player = player else {
            error = "Player could not be initialized"
            return
        }
        
        playbackObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let timeInSeconds = CMTimeGetSeconds(time)
                
                if self.currentObjectRecordIndex + 1 < self.objectRecords.count &&
                    self.objectRecords[self.currentObjectRecordIndex + 1].videoTimeStampInSeconds < timeInSeconds {
                    self.currentObjectRecordIndex += 1
                }
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
    
    private func configure(pass: Pass<Double, URL>) {
        objectIndexToGates[0] = pass.entryGate
        
        videoTimeStampToObjectRecordIndex[pass.entryGate.position] = 0
        
        objectRecords.append(WaterSkiingObjectRecord(
            objectName: "Entry Gate",
            objectIndex: 0,
            objectType: .EntryGate,
            videoTimeStampInSeconds: pass.entryGate.position)
        )
        
        var i = 0, j = 0
        
        let totalCount = pass.buoys.count + pass.wakeCrosses.count
        
        for index in 0..<totalCount {
            if index % 2 == 0 {
                objectIndexToWakeCrosses[i] = pass.wakeCrosses[i]
                videoTimeStampToObjectRecordIndex[pass.wakeCrosses[i].position] = objectRecords.count
                
                objectRecords.append(WaterSkiingObjectRecord(
                    objectName: "Wake Cross \(i + 1)",
                    objectIndex: i,
                    objectType: .WakeCross,
                    videoTimeStampInSeconds: pass.wakeCrosses[i].position)
                )
                
                i += 1
            } else {
                objectIndexToBuoys[j] = pass.buoys[j]
                videoTimeStampToObjectRecordIndex[pass.buoys[j].position] = objectRecords.count
                
                objectRecords.append(WaterSkiingObjectRecord(
                    objectName: "Buoy \(j + 1)",
                    objectIndex: j,
                    objectType: .Buoy,
                    videoTimeStampInSeconds: pass.buoys[j].position)
                )
                
                j += 1
            }
        }
        
        objectIndexToGates[objectRecords.count] = pass.exitGate
        videoTimeStampToObjectRecordIndex[pass.exitGate.position] = objectRecords.count
        
        objectRecords.append(WaterSkiingObjectRecord(
            objectName: "Exit Gate",
            objectIndex: objectRecords.count,
            objectType: .ExitGate,
            videoTimeStampInSeconds: pass.exitGate.position)
        )
    }
    
    func getBuoyByIndex(_ index: Int) -> BuoyBase<Double>? {
        return objectIndexToBuoys[index]
    }
    
    func getGateByIndex(_ index: Int) -> GateBase<Double>? {
        return objectIndexToGates[index]
    }
    
    func getWakeCrossByIndex(_ index: Int) -> WakeCrossBase<Double>? {
        return objectIndexToWakeCrosses[index]
    }
}
