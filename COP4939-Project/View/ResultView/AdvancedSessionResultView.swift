//
//  VideoView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/24/23.
//

import Foundation
import SwiftUI
import AVKit

struct AdvancedSessionResultView : View {
    @EnvironmentObject var passVideoViewModel: WaterSkiingPassVideoViewModel
    @EnvironmentObject var passViewModel: WaterSkiingPassViewModel
    
    @State private var isPlaying = false
    @State private var showPlayButton = false
    @State private var highlightedRow = -1
    
    @State private var showGatePopup = false
    @State private var showBuoyPopup = false
    @State private var showWakeCrossPopup = false
    
    @State private var chosenObjectRecord: WaterSkiingObjectRecord?
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center) {
                VideoPlayer(player: passVideoViewModel.player)
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
                        guard let player = passVideoViewModel.player else { return }
                        player.pause()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.orange, lineWidth: 1)
                    )
                
                ScrollViewReader { scrollProxy in
                    List {
                        createHeaderRow()
                            .frame(maxWidth: .infinity)
                            .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                return 0
                            }
                            .alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
                                return viewDimensions.width
                            }
                            .listRowBackground(Color.clear)
                            .foregroundStyle(Color.orange)
                            .listRowSeparator(.automatic)
                            .listRowSeparatorTint(.orange)
                        
                        ForEach(0..<passVideoViewModel.objectRecords.count, id: \.self) { index in
                            let record = passVideoViewModel.objectRecords[index]
                            
                            createRow(record: record, index: index)
                                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                    return 0
                                }
                                .alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
                                    return viewDimensions.width
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.automatic)
                                .listRowSeparatorTint(.orange)
                        }
                        
                        HStack(spacing: 0) {
                            Text("Score: ")
                                .frame(maxWidth: .infinity)
                            Text("\(passViewModel.pass?.score ?? -1)")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return 0
                        }
                        .alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
                            return viewDimensions.width
                        }
                        .listRowBackground(Color.clear)
                        .background(Color.black)
                        .foregroundStyle(Color.orange)
                    }
                    .onChange(of: passVideoViewModel.curentPlayingRecord) {
                        guard passVideoViewModel.curentPlayingRecord != nil else { return }
                        
                        highlightedRow += 1
                    }
                    .onChange(of: highlightedRow) {
                        withAnimation {
                            scrollProxy.scrollTo(highlightedRow, anchor: .center)
                        }
                    }.scrollContentBackground(.hidden)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .allowsHitTesting(!isPopupToggled())
                
                if isPopupToggled(), let chosenObjectRecord = chosenObjectRecord {
                    ZStack {
                        if showGatePopup, let gate = passVideoViewModel.getGateByIndex(chosenObjectRecord.objectIndex) {
                            GatePopup(
                                showPopup: $showGatePopup,
                                title: chosenObjectRecord.objectName,
                                gate: gate
                            )
                        } else if showBuoyPopup, let buoy = passVideoViewModel.getBuoyByIndex(chosenObjectRecord.objectIndex) {
                            BuoyPopup(
                                showPopup: $showBuoyPopup,
                                title: chosenObjectRecord.objectName,
                                buoy: buoy
                            )
                        } else if showWakeCrossPopup, let wakeCross = passVideoViewModel.getWakeCrossByIndex(chosenObjectRecord.objectIndex) {
                            WakeCrossPopup(
                                showPopup: $showWakeCrossPopup,
                                title: chosenObjectRecord.objectName,
                                wakeCross: wakeCross
                            )
                        }
                    }
                    .onAppear(perform: {
                        if isPlaying {
                            togglePlayback()
                        }
                    })
                }
            }
        }
    }
    
    private func createRow(record: WaterSkiingObjectRecord, index: Int) -> some View {
        return HStack(spacing: 0) {
            Text(formatTime(seconds: record.videoTimeStampInSeconds))
                .frame(maxWidth: .infinity)
            Text(record.objectName)
                .frame(maxWidth: .infinity)
        }
        .id(index)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .foregroundStyle(Color.orange)
        .clipShape(record == passVideoViewModel.curentPlayingRecord ? RoundedRectangle(cornerRadius: 10) : RoundedRectangle(cornerRadius: 0))
        .overlay(
            record == passVideoViewModel.curentPlayingRecord ?
            RoundedRectangle(cornerRadius: 10).stroke(.orange, lineWidth: 4) : RoundedRectangle(cornerRadius: 0).stroke(.orange, lineWidth: 0.4)
        )
        .onTapGesture(perform: {
            passVideoViewModel.seekTo(record: record)
            highlightedRow = index
        })
        .onLongPressGesture(perform: {
            chosenObjectRecord = WaterSkiingObjectRecord(
                id: record.id,
                objectName: record.objectName,
                objectIndex: record.objectIndex,
                objectType: record.objectType,
                videoTimeStampInSeconds: record.videoTimeStampInSeconds
            )
            
            togglePopup(type: record.objectType)
        })
    }
    
    private func isPopupToggled() -> Bool {
        return showBuoyPopup || showGatePopup || showWakeCrossPopup
    }
    
    private func togglePopup(type: WaterSkiingObjectType) {
        switch type {
        case .Buoy:
            showBuoyPopup.toggle()
        case .WakeCross:
            showWakeCrossPopup.toggle()
        case .EntryGate:
            fallthrough
        case .ExitGate:
            showGatePopup.toggle()
        }
    }
    
    private func formatTime(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? ""
    }
    
    private func createHeaderRow() -> some View {
        return HStack(spacing: 0) {
            Text("Time frame")
                .frame(maxWidth: .infinity)
            Text("Position")
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func togglePlayback() {
        guard let player = passVideoViewModel.player else { return }
        
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

extension AVPlayerViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.showsPlaybackControls = false
    }
}
