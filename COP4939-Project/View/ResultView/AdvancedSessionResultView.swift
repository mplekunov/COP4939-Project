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
    @EnvironmentObject var passViewModel: PassViewModel
    
    @State private var isPlaying = false
    @State private var showPlayButton = false
    @State private var highlightedRow = -1
    
    @State private var showGatePopup = false
    @State private var showBuoyPopup = false
    @State private var showWakeCrossPopup = false
    
    @State private var activeElement: PassElement?
    
    private var currentRow: Binding<Int> {
        Binding(
            get: {
                guard let index = passViewModel.currentElement?.index else { return 0 }
                return index
            },
            set: { _ in }
        )
    }
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center) {
                VideoPlayer(player: passViewModel.player)
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
                        passViewModel.player.pause()
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
                            .listRowBackground(Color.black)
                            .foregroundStyle(Color.orange)
                            .listRowSeparator(.automatic)
                            .listRowSeparatorTint(.orange)
                        
                        ForEach(0..<passViewModel.timeStamps.count, id: \.self) { index in
                            let element = passViewModel.timeStamps[index]
                            
                            HStack(spacing: 0) {
                                Text(formatTime(seconds: element.timeStamp))
                                    .frame(maxWidth: .infinity)
                                Text(element.name)
                                    .frame(maxWidth: .infinity)
                            }
                            .id(index)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                return 0
                            }
                            .alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
                                return viewDimensions.width
                            }
                            .background(Color.black)
                            .foregroundStyle(Color.orange)
                            .clipShape(element == passViewModel.currentElement ? RoundedRectangle(cornerRadius: 10) : RoundedRectangle(cornerRadius: 0))
                            .overlay(
                                (element == passViewModel.currentElement ? RoundedRectangle(cornerRadius: 10) : RoundedRectangle(cornerRadius: 0))
                                    .stroke(.orange, lineWidth: 2)
                            )
                            .listRowBackground(Color.black)
                            .listRowSeparator(.automatic)
                            .listRowSeparatorTint(.orange)
                            .onTapGesture(perform: {
                                passViewModel.seekTo(element: element)
                                highlightedRow = index
                            })
                            .onLongPressGesture(perform: {
                                activeElement = PassElement(
                                    id: element.id,
                                    index: element.index,
                                    name: element.name,
                                    type: element.type,
                                    timeStamp: element.timeStamp
                                )
                                
                                togglePopup(type: element.type)
                            })
                        }
                        .onChange(of: passViewModel.currentElement) {
                            guard passViewModel.currentElement != nil else { return }
                            
                            highlightedRow += 1
                        }
                        .onChange(of: highlightedRow) {
                            withAnimation {
                                scrollProxy.scrollTo(highlightedRow, anchor: .center)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .allowsHitTesting(!isPopupToggled())
            
            if isPopupToggled(), let activeElement = activeElement {
                ZStack {
                    if showGatePopup, let gate = passViewModel.getGateByIndex(activeElement.index) {
                        GatePopup(
                            showPopup: $showGatePopup,
                            title: activeElement.name,
                            gate: gate
                        )
                    } else if showBuoyPopup, let buoy = passViewModel.getBuoyByIndex(activeElement.index) {
                        BuoyPopup(
                            showPopup: $showBuoyPopup,
                            title: activeElement.name,
                            buoy: buoy
                        )
                    } else if showWakeCrossPopup, let wakeCross = passViewModel.getWakeCrossByIndex(activeElement.index) {
                        WakeCrossPopup(
                            showPopup: $showWakeCrossPopup,
                            title: activeElement.name,
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
    
    private func isPopupToggled() -> Bool {
        return showBuoyPopup || showGatePopup || showWakeCrossPopup
    }
    
    private func togglePopup(type: CoursePoint) {
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
        showPlayButton = true
        
        if !isPlaying {
            passViewModel.player.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showPlayButton = false
            }
        } else {
            passViewModel.player.pause()
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

struct Preview: PreviewProvider {
    static var previews: some View {
        AdvancedSessionResultView()
            .environmentObject(PassViewModel(pass: generateTestPass()))
    }
}


