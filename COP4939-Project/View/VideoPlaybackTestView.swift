//
//  TestView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 1/5/24.
//

import Foundation
import SwiftUI
import AVKit

class VideoPlaybackTestViewModel : ObservableObject {
    @Published var player: AVPlayer?
    @Published var error: String?
    
    init() {
        let videoManager = VideoManager()
        videoManager.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let documentsDirectory = documentsDirectory else { return }
        
        Task {
            let fileURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
            
            let movieOutputID = "asdqwerty"
            let videoURL = documentsDirectory.appendingPathComponent(movieOutputID + "." + fileURL.pathExtension)
            
            do {
                try FileManager.default.removeItem(at: videoURL)
                
                try await videoManager.trimVideo(source: fileURL, to: videoURL, startTime: CMTime(seconds:50, preferredTimescale: 1), endTime: CMTime(seconds: 100, preferredTimescale: 1))
            } catch {
                print("\(error)")
            }
            
            DispatchQueue.main.async {
                print(videoURL)
                self.player = AVPlayer(url: videoURL)
            }
        }
    }
}

struct VideoPlaybackTestView : View {
    @State private var isPlaying = false
    @State private var showPlayButton = false
    
    @StateObject private var vm = VideoPlaybackTestViewModel()
    
    var body: some View {
        ZStack {
            if let error = vm.error {
                Text(error)
            } else if let player = vm.player {
                VideoPlayer(player: player)
                    .onAppear {
                        togglePlayback()
                    }
                    .onTapGesture(perform: {
                        togglePlayback()
                    })
                    .overlay(alignment: .center, content: {
                        if showPlayButton {
                            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                                .foregroundColor(.orange)
                                .font(.system(size: 50))
                                .onTapGesture(perform: togglePlayback)
                                .padding()
                        }
                    })
                    .onDisappear {
                        guard let player = vm.player else { return }
                        player.pause()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.orange, lineWidth: 1)
                    )
            }
        }
    }
    
    private func togglePlayback() {
        guard let player = vm.player else { return }
        
        showPlayButton = true
        
        if !isPlaying {
            player.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showPlayButton = false
            }
        } else {
            player.pause()
        }
        
        isPlaying.toggle()
    }
}
