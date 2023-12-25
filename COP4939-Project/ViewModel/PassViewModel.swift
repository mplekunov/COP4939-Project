//
//  VidePlaybackViewModel.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/24/23.
//

import Foundation
import AVKit

struct PassElement : Identifiable, Equatable {
    let id: UUID
    let index: Int
    let name: String
    let type: CoursePoint
    let timeStamp: Double
    
    init(id: UUID, index: Int, name: String, type: CoursePoint, timeStamp: Double) {
        self.id = id
        self.index = index
        self.name = name
        self.type = type
        self.timeStamp = timeStamp
    }
    
    init(index: Int, name: String, type: CoursePoint, timeStamp: Double) {
        id = UUID()
        self.index = index
        self.name = name
        self.type = type
        self.timeStamp = timeStamp
    }
}

enum CoursePoint {
    case EntryGate
    case ExitGate
    case Buoy
    case WakeCross
}

class PassViewModel : ObservableObject {
    @Published public private(set) var currentPlaybackTime: Double = 0
    @Published public private(set) var currentElement: PassElement?

    private let fileManager = DatabaseManager()
    
    private var indexToBuoys: Dictionary<Int, Buoy> = [:]
    private var indexToGates: Dictionary<Int, Gate> = [:]
    private var indexToWakeCrosses: Dictionary<Int, WakeCross> = [:]
    
    private var timeStampToIndex: Dictionary<Double, Int> = [:]
    
    private var currentIndex = -1
    
    public private(set) var player: AVPlayer
    
    public private(set) var timeStamps: [PassElement] = []
    
    private var asset: AVAsset
    
    private var observer: Any?
    
    private let operationQueue: OperationQueue = OperationQueue()
    
    public private(set) var pass: Pass
    
    init(pass: Pass) {
        self.pass = pass
        
        let videoURL = fileManager.getURL(id: pass.videoId)
        
        player = AVPlayer(url: videoURL)
        asset = AVAsset(url: videoURL)
        
        observer = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            
            let timeInSeconds = CMTimeGetSeconds(time)
            
            currentPlaybackTime = timeInSeconds
            
            if currentIndex + 1 < timeStamps.count &&
                timeStamps[currentIndex + 1].timeStamp < currentPlaybackTime {
                currentElement = timeStamps[currentIndex + 1]
                currentIndex += 1
            }
        }
        
        setup()
    }
    
    func seekTo(element: PassElement) {
        let seekTime = CMTime(seconds: element.timeStamp, preferredTimescale: 1)
        let tolerance = CMTime(seconds: 1, preferredTimescale: 2)
        
        player.seek(to: seekTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
        currentPlaybackTime = CMTimeGetSeconds(player.currentTime())
        
        guard let index = timeStampToIndex[element.timeStamp] else { 
            currentElement = nil
            currentIndex = -1
            return
        }
        
        currentElement = timeStamps[index]
        currentIndex = index - 1
    }
    
    private func setup() {
        indexToGates[0] = pass.entryGate
        
        timeStampToIndex[pass.entryGate.timeWhenPassed] = 0
        
        timeStamps.append(PassElement(index: 0, name: "Entry Gate", type: .EntryGate, timeStamp: pass.entryGate.timeWhenPassed))
        
        var i = 0, j = 0
        
        let totalCount = pass.buoys.count + pass.wakeCrosses.count
        
        for index in 0..<totalCount {
            if index % 2 == 0 {
                indexToWakeCrosses[i] = pass.wakeCrosses[i]
                timeStampToIndex[pass.wakeCrosses[i].timeWhenPassed] = timeStamps.count
                
                timeStamps.append(PassElement(index: i, name: "Wake Cross \(i + 1)", type: .WakeCross, timeStamp: pass.wakeCrosses[i].timeWhenPassed))
                
                i += 1
            } else {
                indexToBuoys[j] = pass.buoys[j]
                timeStampToIndex[pass.buoys[j].timeWhenPassed] = timeStamps.count
                
                timeStamps.append(PassElement(index: i, name: "Buoy \(j + 1)", type: .Buoy, timeStamp: pass.buoys[j].timeWhenPassed))
                
                j += 1
            }
        }
        
        indexToGates[timeStamps.count] = pass.exitGate
        timeStampToIndex[pass.exitGate.timeWhenPassed] = timeStamps.count
        
        timeStamps.append(PassElement(index: timeStamps.count, name: "Exit Gate", type: .ExitGate, timeStamp: pass.exitGate.timeWhenPassed))
    }
    
    func getBuoyByIndex(_ index: Int) -> Buoy? {
        return indexToBuoys[index]
    }
    
    func getGateByIndex(_ index: Int) -> Gate? {
        return indexToGates[index]
    }
    
    func getWakeCrossByIndex(_ index: Int) -> WakeCross? {
        return indexToWakeCrosses[index]
    }
}
