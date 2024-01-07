//
//  BuoyPopup.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/24/23.
//

import Foundation
import SwiftUI

struct BuoyPopup<T> : View where T : Codable {
    @Binding var showPopup: Bool
    
    var title: String
    var buoy: BuoyBase<T>
    
    var body: some View {
        ZStack{
            VStack{
                HStack(alignment: .top) {
                    Spacer()
                    Button(action: { showPopup = false }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.orange)
                            .padding()
                    }
                }
                
                Spacer()
                
                Text(title)
                    .font(.title)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Max Speed: ")
                            .padding(.bottom)
                        Text("Max Pitch: ")
                            .padding(.bottom)
                        Text("Max Roll: ")
                    }.padding()
                    
                    VStack(alignment: .leading) {
                        Text("\(buoy.maxSpeed.formatted())")
                            .padding(.bottom)
                        Text("\(buoy.maxPitch.formatted())")
                            .padding(.bottom)
                        Text("\(buoy.maxRoll.formatted())")
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .foregroundStyle(.orange)
        .frame(
            width: UIScreen.main.bounds.width * 0.9,
            height: UIScreen.main.bounds.height * 0.35
        )
        .background(Color.black.opacity(0.95).blur(radius: 10))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.orange, lineWidth: 1)
        )
        
    }
}

struct BuoyPopupPreview: PreviewProvider {
    private static func getCoordinate(lat: Double, lon: Double) -> Coordinate {
        return Coordinate(longitude: Measurement(value: lon, unit: .degrees), latitude: Measurement(value: lat, unit: .degrees))
    }
    
    static var previews: some View {
        BuoyPopup<Coordinate>(
            showPopup: .constant(true),
            title: "Buoy 1",
            buoy: BuoyBase<Coordinate>(
                maxSpeed: Measurement(value: 20, unit: .metersPerSecond),
                maxRoll: Measurement(value: 3, unit: .degrees),
                maxPitch: Measurement(value: 2, unit: .degrees),
                position: getCoordinate(lat: 0.02, lon: 0.1),
                timeOfRecordingInSeconds: 0
        ))
    }
}
