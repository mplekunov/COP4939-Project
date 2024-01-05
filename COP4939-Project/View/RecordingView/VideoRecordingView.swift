//
//  VideoRecordingView.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/20/23.
//

import Foundation
import SwiftUI

struct VideoRecordingView : View {
    var image: CGImage?
    private let label = Text("Camera feed")
    
    var body: some View {
        ZStack {
            if let image = image {
                GeometryReader { geometry in
                    Image(image, scale: 1.0, orientation: .up, label: label)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center)
                        .clipped()
                }
            } else {
                Text("Camera Feed is not available.")
            }
        }
    }
}

