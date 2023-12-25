//
//  WakeCrossPopup.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/24/23.
//

import Foundation
import SwiftUI

struct WakeCrossPopup : View {
    @Binding var showPopup: Bool
    
    var title: String
    var wakeCross: WakeCross
    
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
                            .padding(.bottom)
                        Text("Max Angle: ")
                            .padding(.bottom)
                        Text("Max Acceleration: ")
                            .padding(.bottom)
                        Text("Max G-Force: ")
                    }.padding()
                    
                    VStack(alignment: .leading) {
                        Text("\(wakeCross.maxSpeed.formatted())")
                            .padding(.bottom)
                        Text("\(wakeCross.maxPitch.formatted())")
                            .padding(.bottom)
                        Text("\(wakeCross.maxRoll.formatted())")
                            .padding(.bottom)
                        Text("\(wakeCross.maxAngle.formatted())")
                            .padding(.bottom)
                        Text("\(wakeCross.maxAcceleration.formatted())")
                            .padding(.bottom)
                        Text("\(wakeCross.maxGForce.formatted())")
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .foregroundStyle(.orange)
        .frame(
            width: UIScreen.main.bounds.width * 0.9,
            height: UIScreen.main.bounds.height * 0.5
        )
        .background(Color.black.opacity(0.95).blur(radius: 10))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.orange, lineWidth: 1)
        )
    }
}


struct WakeCrossPopupPreview: PreviewProvider {
    private static func getCoordinate(lat: Double, lon: Double) -> Coordinate {
        return Coordinate(latitude: Measurement(value: lat, unit: .degrees), longitude: Measurement(value: lon, unit: .degrees))
    }
    
    static var previews: some View {
        WakeCrossPopup(showPopup: .constant(true), title: "Wake Cross 1", wakeCross: WakeCross(
            location: getCoordinate(lat: 0.22222, lon: 0.3222222),
            maxSpeed: Measurement(value: 2, unit: .milesPerHour),
            maxRoll: Measurement(value: 3, unit: .degrees),
            maxPitch: Measurement(value: 2, unit: .degrees),
            maxAngle: Measurement(value: 1, unit: .degrees),
            maxGForce: Measurement(value: 4, unit: .gravity),
            maxAcceleration: Measurement(value: 10, unit: .metersPerSecondSquared),
            timeWhenPassed: 0)
        )
    }
}
